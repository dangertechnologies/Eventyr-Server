# == Schema Information
#
# Table name: users
#
#  id                   :bigint(8)        not null, primary key
#  email                :string
#  password             :string
#  password_digest      :string
#  remember_created_at  :datetime
#  sign_in_count        :integer          default(0), not null
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string
#  last_sign_in_ip      :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  name                 :string
#  personal_points      :integer
#  points               :integer
#  role_id              :bigint(8)
#  country_id           :bigint(8)
#  scan_radius          :float
#  authentication_token :string
#  auto_share           :boolean
#  avatar               :text
#  allow_coop           :boolean
#  avatar_url           :string
#
# Indexes
#
#  index_users_on_country_id       (country_id)
#  index_users_on_email            (email) UNIQUE
#  index_users_on_name             (to_tsvector('english'::regconfig, (name)::text)) USING gin
#  index_users_on_personal_points  (personal_points)
#  index_users_on_points           (points)
#  index_users_on_role_id          (role_id)
#

class User < ApplicationRecord
  has_secure_token :password
  has_secure_password

  InvalidCoordinates = Class.new(StandardError)

  belongs_to :role
  delegate :permission_level, :name, :description, to: :role, prefix: true
  belongs_to :country, required: false
  delegate :name, to: :country, prefix: true
  has_one :profile_picture, -> {where profile_picture: true}, class_name: 'Image', as: 'resource'
  delegate :path, to: :profile_picture, prefix: true
  has_many :identities
  delegate :token, :token_expires, :provider, to: :identity, prefix: true

  # User has friends!
  has_and_belongs_to_many :friends, class_name: "User", join_table: "friends", foreign_key: "user_a", association_foreign_key: "user_b"

  validates_associated :role


  ###
  ### REQUESTS AND MESSAGING RELATIONSHIPS
  ###
  has_many :notifications
  has_many :coop_requests           # All sent coop requests
  has_many :received_coop_requests, class_name: 'CoopRequest', foreign_key: 'target_id'  # All received coop requests
  has_many :friend_requests, class_name: "FriendRequest", foreign_key: "to_id"

  ###
  ### ACHIEVEMENT RELATIONSHIPS
  ###
  has_many :personal_achievements, class_name: 'Achievement' # These are all Achievements the user has created
  has_many :unlocked                # These are all the users unlocked achievements
  has_many :objective_progress      # These are all objectives the user has completed or started working on
  has_many :tracked                 # And these are all the users tracked Achievements
  has_many :lists                   # And all the lists
  has_many :achievements, through: :tracked
  has_many :titles, through: :unlocked

  ###
  ### SHARING RELATIONSHIPS
  ###
  has_many :shared_achievements     # These are the Achievements the user has shared
  has_many :incoming_achievements, class_name: 'SharedAchievement', foreign_key: 'target_id' # And these are incoming shares

  has_many :shared_lists
  has_many :received_lists, class_name: 'SharedList', foreign_key: 'target_id' # All lists shared with user

  has_many :sent_achievements, through: :shared_achievements, class_name: 'Achievement'
  has_many :received_achievements, through: :incoming_achievements, class_name: 'Achievement'



  def self.from_token_request request
    # Returns a valid user, `nil` or raise `Knock.not_found_exception_class_name`
    # e.g.
    #   email = request.params["auth"] && request.params["auth"]["email"]
    #   self.find_by email: email
    puts request.params.to_h
  end

  # Upvotes an achievement
  # @param [Achievement|Integer] achievement
  def upvote(achievement)
    achievement_id = achievement === Integer ? achievement : achievement.id

    vote = Vote.find_or_initialize_by(achievement_id: achievement_id, user: self)
    vote.assign_attributes(value: 1)
    vote.save
  end

  # Downvotes an achievement
  # @param [Achievement|Integer] achievement
  def downvote(achievement)
    achievement_id = achievement === Integer ? achievement : achievement.id

    vote = Vote.find_or_initialize_by(achievement_id: achievement_id, user: self)
    vote.assign_attributes(value: -1)
    vote.save
  end

  # Checks if the user has the given role
  # @param [Symbol|String] name
  def has_role?(name)
    role.name.downcase == name.to_s
  end

  # Returns amount of times a user has cooperated with another user
  #
  # @param [User] other_user The other user to count times cooperated with
  # @return [Integer] Amount of times cooperated with other_user
  def times_cooperated_with(other_user)
    sent_coop_reqs = CoopRequest.where(user: self, target: other_user).count
    received_coop_reqs = CoopRequest.where(user: other_user, target: self).count

    if sent_coop_reqs + received_coop_reqs > 1
      return (sent_coop_reqs + received_coop_reqs)/2
    else
      return (sent_coop_reqs + received_coop_reqs)
    end
  end

  # Notifies a user by creating a new (unseen) notification
  #
  # @param target_object The object to notify the user about (new relationship? new unlock?)
  # @param from Optional parameter, if the Notification was sent on another users behalf
  # @return [Notification]
  def notify(target_object, from = nil)
    if from.nil?
      notifications.create(target: target_object, seen: false)
    else
      notifications.create(target: target_object, from: from, seen: false)
    end
  end

  # Returns all unseen notifications
  #
  # @return [Array<Notification>]
  def unseen_notifications
    notifications.where(seen: false)
  end

  # Checks if a user is eligible to complete the provided Achievement
  #
  # @param [Achievement] The Achievement to verify eligibility for
  # @return [Boolean]
  def eligible?(achievement)

    # Check if the achievement has been unlocked before
    return false if @achievements.include?(achievement) unless @achievements.nil?

    # Check if the achievement has parents and if all parents have been unlocked
    return false if achievement.has_parents? && achievement.parents.select{ |p| @achievements.include? p }.size < achievements.parents.size

    # Check if the achievement has a time limit and if that time has passed
    return false if achievement.expires? and achievement.expires < Time.now

    # If all checks passed, return true
    return true

  end

  # Checks if a user has previously unlocked the provided Achievement
  #
  # @param [Achievement] the achievement to check users progress for
  # @return [Boolean]
  def unlocked?(achievement)
    Unlocked.where(achievement: achievement, user: self).exists?
  end

  # Checks whether or not the user is currently tracking an achievement
  # and returns 1 if tracked, 2 if pinned and 0 if neither.
  #
  # @param [Achievement] the achievement to check tracking status for
  # @return [Integer]
  def tracking?(achievement)
    t = Tracked.where(achievement: achievement, user: self).first
    return 0 if t.nil?
    return 1 unless t.pinned
    return 2
  end

  # Automatically tracks or untracks Achievements based on users location.
  # Does not untrack Pinned achievements.
  #
  # @param [Hash] loc
  # @option loc [BigDecimal] :x The Latitude
  # @option loc [BigDecimal] :y The Longitude
  # @return [Array<Tracked>]
  def refresh_suggested_achievements(latitude: nil, longitude: nil)
    raise InvalidCoordinates.new("Neither latitude nor longitude can be nil") if latitude.nil? || longitude.nil?

    # Untrack those that are not pinned, and outside of the range
    new_tracked = Achievement.joins(:objectives).where.not(
      id: Unlocked.where(user_id: id).pluck(:achievement_id) + tracked.pluck(:id)
    ).by_distance(origin: [latitude, longitude]).limit(50).uniq

    tracked.where.not(achievement_id: new_tracked.pluck(:id), pinned: false).where(user_id: id).destroy_all
    
    Tracked.create!(
      new_tracked.map { |achievement|
        {
          achievement: achievement,
          user_id: id,
          pinned: false
        }
      }.reject{ |proto| 
          # Dont attempt to re-create already tracked Achievements
          tracked.map(&:achievement_id).include?(proto[:achievement].id)
        }
    )
  end

  # Tracks an Achievement
  #
  # @param [Achievement]
  # @return [Tracked]
  def track(achievement)

    # Set up a new relationship for tracking
    track = Tracked.new(achievement: achievement, user: self, pinned: false)

    # Only save the relationship if both the user and the achievement is valid
    if track.valid?
      track.save!
      track
    else
      {errors: {messages: track.errors.messages } }
    end
  end

  # Untracks (AND unpins) an achievement
  #
  # @param [Achievement]
  def untrack(achievement)

    tracked = Tracked.where(achievement: achievement, user: self)
    if tracked.exists?
      tracked.destroy!
    else
      { errors: {messages: 'Achievement was not tracked'}}
    end
  end

  # User Pins an Achievement(forced track)
  #
  # @param [Achievement]
  def pin(achievement)

    # Set up a relationship
    track = Tracked.where(achievement: achievement, user: self).first
    track = Tracked.create(achievement: achievement, user: self) if track.nil?
    track.pinned = true

    # Only save the relationship if both the user and the achievement is valid
    if track.valid?
      track.save!
      track
    else
      {errors: {messages: track.errors.messages} }
    end
  end

  # Unpins an Achievement but keeps it tracked
  #
  # @param [Achievement]
  def unpin(achievement)
    tracked = Tracked.where(achievement: achievement, user: self).first
    if tracked.nil?
      { errors: {messages: 'Achievement was not tracked'}}
    else
      tracked.pinned = false
      tracked.save!
    end
  end

  # Unlocks an Achievement
  #
  # @param [Achievement]
  # @param [Hash] options
  # @option options :x The Latitude
  # @option options :y The Longitude
  # @option options :time Time of completion (if offline)
  def unlock(achievement, x: nil, y: nil, time: nil)
    achievement.unlock(self, x: x, y: y, time: time)
  end

  # Check if user is friends with another user
  #
  # @param [Integer]
  # @return [Boolean]
  def friends_with? (user)
    friends.where(id: user.id).exists?
  end


end
