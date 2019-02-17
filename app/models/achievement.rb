# == Schema Information
#
# Table name: achievements
#
#  id                  :bigint(8)        not null, primary key
#  name                :string
#  short_description   :string
#  full_description    :text
#  base_points         :integer
#  expires             :date
#  has_parents         :boolean
#  is_multiplayer      :boolean
#  is_global           :boolean
#  is_suggested_global :boolean
#  user_id             :bigint(8)
#  kind                :integer
#  icon                :integer
#  category_id         :bigint(8)
#  mode                :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  hash_identifier     :string
#  upvotes             :integer
#  downvotes           :integer
#
# Indexes
#
#  index_achievements_on_category_id        (category_id)
#  index_achievements_on_full_description   (to_tsvector('english'::regconfig, full_description)) USING gin
#  index_achievements_on_icon               (icon)
#  index_achievements_on_kind               (kind)
#  index_achievements_on_mode               (mode)
#  index_achievements_on_name               (to_tsvector('english'::regconfig, (name)::text)) USING gin
#  index_achievements_on_short_description  (to_tsvector('english'::regconfig, (short_description)::text)) USING gin
#  index_achievements_on_user_id            (user_id)
#

class Achievement < ApplicationRecord
  include HasIcon       # It comes with an icon as well
  belongs_to :user       # An Achievement belongs to the user who created it
  

  # It always has one type.
  enum kind: {
    LOCATION: 15,  # Visit a location
    ROUTE: 50,     # Perform actions (no location-based objectives)
    DISCOVERY: 35, # Visit multiple locations
    ACTION: 25,    # Perform a task
  }

  # Mode values are multipliers, and will be used to calculate the 
  # points of an Achievement.
  enum mode: {
    EASY: 5,
    NORMAL: 10,
    DIFFICULT: 15,
    EXTREME: 20
  }

  belongs_to :category   # one category
  delegate :title, :icon, :points, to: :category, prefix: true

  # Find Achievements where all objectives are unlocked by the user,
  # and the user hasn't already unlocked the achievement
  scope :unlockable, -> (user) {
    includes(objectives: :objective_progress)\
    .where(objectives: { objective_progresses: { user_id: user.id, completed: true }})\
    .where.not(id: Unlocked.where(user: user).pluck(:achievement_id))
  }

  
  has_and_belongs_to_many :objectives   # Every Achievement consists of one or several objectives
  acts_as_mappable through: :objectives
  has_one :title                        # Some Achievements may yield a title as a reward

  has_many :unlocked
  has_many :tracked
  has_many :list_content
  has_many :shared_achievement
  has_many :achievement_dependencies

  has_many :users, through: :unlocked
  has_many :users, through: :tracked
  has_many :users, through: :shared_achievement
  has_many :lists, through: :list_content

  # Validate the values!
  validates :base_points, :name, :short_description, :full_description, :icon, :kind, :category, :mode, presence: true
  validates :base_points, numericality: true
  validates :name, length: { minimum: 5, maximum: 255}
  validates :short_description, length: { minimum: 10, maximum: 255}
  #validates :full_description, length: { minimum: 5, tokenizer: lambda {|str| str.scan(/\w+/)}}

  # Returns the calculated points for the Achievement
  # @return [Integer] Points earned for completing the Achievement
  def calculated_points
    mode_multiplier = (Achievement.modes[mode].to_f / 10).to_f
    type_points = Achievement.kinds[kind]
    
    (mode_multiplier*(category_points + type_points + base_points + objectives.sum(&:base_points)))
  end

  # Returns true if there's an image for the achievement
  #
  # @return [Boolean]
  def has_image?
    return false
  end



  # Check if a user has completed all objectives for this achievement
  #
  # @param [User]
  def all_objectives_completed_by? (user)
    obj_ids = []

    objectives.each do |t|
        obj_ids << t.id
    end

    progresses = ObjectiveProgress.where(user: user, objective_id: obj_ids)

    # If the user doesnt have a progress object on each objective,
    # return false
    return false if progresses.size < obj_ids.size

    # Now that the user does, assume he's done unless proven otherwise
    decision = true

    progresses.each do |p|
      # Check each progress and see if it is done
      decision = false unless p.completed?
    end

    decision
  end


  # Unlocks an Achievement
  #
  # @param [User]
  # @param [Hash] options
  # @option options :x The Latitude
  # @option options :y The Longitude
  # @option options :time Time of completion (if offline)
  def unlock(user, x: nil, y: nil, time: nil)
    # If time was nil, set to current time
    time ||= DateTime.now

    # Check if user has already unlocked this Achievement?
    return unlock_check if unlock_check = Unlocked.find_by(user: user, achievement_id: id)
    
    # Verify that the user has completed all parent achievements (if any)
    # First, check if the Achievement has a parent
    if has_parents?
      unfinished = []

      # Iterate through dependencies (only direct parents!)
      achievement_dependencies.each do |dep|
        # Has user unlocked this?
        unfinished << dep unless user.unlocked? (dep.dependency)
      end
      return {errors: {messages: 'User is not eligible for #{name}.', dependencies: unfinished} } unless unfinished.empty?
    end




    # Unlock criteria depends on the type of achievement
    case kind
    when 'LOCATION', 'ROUTE', 'DISCOVERY'   # All these are location based and the main difference
                                            # is how they are triggered. Route is essentially the
                                            # same as Location except a Route *always* has parents (or children)

      # If the user has not completed all objectives, check if any of them can be completed
      # and complete it.
      # For Routes, this should ONLY be possible if all PREVIOUS ones are completed
      route_sequence_check = true

      objectives.each do |obj|
        begin
          if kind == "route"
            if route_sequence_check && obj.kind == "LOCATION" && obj.can_complete?(x: x, y: y)
              obj.complete(user: user, x: x, y: y, time: time)
            elsif obj.kind == "LOCATION" && !obj.can_complete?(x: x, y: y)
              route_sequence_check = false
            end
          # TODO: Update route to check for objective_progress and which order they were updated in
          elsif obj.kind == "LOCATION" && obj.can_complete?(x: x, y: y)
            
            obj.complete(user: user, x: x, y: y, time: time)
          end
        rescue Objective::TooFarAwayException
          next
        end
      end

      # If all objectives have been completed, the Achievement can now be unlocked!
      return {errors: {messages: 'Too far away: #{distance}km'}} unless all_objectives_completed_by?(user)
      unlock = Unlocked.new(achievement: self, user: user)

      # If the unlock object is valid, continue checking if a coop is pending
      return {errors: { messages: unlock.errors.messages }} unless unlock.valid?

      # Start coop_bonus at 0
      this_users_coop_bonus = 0

      # TODO: Support looking up CoopRequest by list: { achievements: { id: id }}
      CoopRequest.where(pending: false,  achievement_id: id, user_id: user.id).or(
        CoopRequest.where(pending: false,  achievement_id: id, target_id: user.id)
      ).each do |c|
        # Check if the partner has unlocked the achievement, and when
        if coop.user_id == user.id
          # If the user sent the request, use coop.target as user object
          u = Unlocked.where(achievement: self, user: c.target)

          # Save friend object for later
          friend = coop.target
        else
          # Else use regular user object
          u = Unlocked.where(achievement: self, user: c.user)

          # Save friend object for later
          friend = coop.user
        end

        # If u exists, the other user had unlocked, so continue to update his/her coop bonus
        if u.exists? && (options[:time] - u.created_at) < 1.day
          # The other user has unlocked, so award both a coop bonus
          times_cooperated_together = user.times_cooperated_with(c.target)
          times_cooperated_together = 3 unless times_cooperated_together > 2

          coop_bonus = calculated_points * (Settings.coop_base_bonus**times_cooperated_together)
          c.complete = true
          c.save!
          # User always gets the biggest coop bonus, so that if
          # the user is also cooperating with somebody else,
          # he/she gets maximum points for bringing a new person to the group
          this_users_coop_bonus = coop_bonus if coop_bonus > this_users_coop_bonus

          # Update both unlocks with a coop bonus!
          u.coop_bonus = coop_bonus
          u.save!

          if is_global
            friend.points = friend.points + coop_bonus
          else
            friend.personal_points = friend.personal_points + coop_bonus
          end
          friend.notify(u, user) # Notify friend about unlock
          friend.save!
        end

      end


      # Save the newly unlocked Achievement with the calculated coop_bonus
      # if any (else 0)
      unlock.assign_attributes(coop_bonus: this_users_coop_bonus, points: calculated_points)
      unlock.save!

      # Update users points with coop_bonus and achievement points
      if is_global?
        user.update_attributes(points:  user.points + calculated_points + this_users_coop_bonus)
      else
        user.update_attributes(personal_points: user.personal_points + calculated_points + this_users_coop_bonus)
      end


      user.save!

      # Remove the tracked Achievement if it existed
      Tracked.where(achievement: self, user: user).destroy_all

      # Notify user
      user.notify(unlock)

      unlock
    when 'Repetition'
      puts "Repetition"
    else
      {errors: 'Unknown Achievement type'}
    end

  end

  # Check if anybody has unlocked this Achievement.
  # An Achievement can only be removed if nobody has unlocked it
  #
  # @return [Boolean]
  def anybody_unlocked?
    Unlocked.where(achievement: self).exists?
  end


  # When an Achievement is destroyed, also remove all:
  # * Cooperation Requests
  # * List references
  # * Notifications mentioning it
  # * Shared Achievements
  # * Tracked relations
  # * Unlocked relations if any (there shouldnt be)
  before_destroy do |this|
    Notification.where(target: this).destroy_all
    CoopRequest.where(achievement_id: this.id).destroy_all
    # ListContent.where(achievement_id: this.id).destroy_all
    SharedAchievement.where(achievement_id: this.id).destroy_all
    Tracked.where(achievement_id: this.id).destroy_all
    Unlocked.where(achievement_id: this.id).destroy_all
  end

end
