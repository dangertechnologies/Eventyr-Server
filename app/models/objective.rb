# == Schema Information
#
# Table name: objectives
#
#  id              :bigint(8)        not null, primary key
#  tagline         :string
#  base_points     :integer
#  required_count  :integer
#  is_public       :boolean          default(FALSE)
#  kind            :integer
#  time_constraint :integer
#  from_timestamp  :datetime
#  to_timestamp    :datetime
#  lat             :float
#  lng             :float
#  alt             :float
#  country_id      :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  hash_identifier :string
#
# Indexes
#
#  index_objectives_on_country_id       (country_id)
#  index_objectives_on_from_timestamp   (from_timestamp)
#  index_objectives_on_kind             (kind)
#  index_objectives_on_lat_and_lng      (lat,lng)
#  index_objectives_on_lng_and_lat      (lng,lat)
#  index_objectives_on_time_constraint  (time_constraint)
#  index_objectives_on_to_timestamp     (to_timestamp)
#

class Objective < ApplicationRecord

  TooFarAwayException = Class.new(StandardError)
  NoUserProvidedException = Class.new(StandardError)
  OutsideTimeRangeException = Class.new(StandardError)


  belongs_to :country
  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
  				   	     :lng_column_name => :lng,
  				   	     :lat_column_name => :lat,
                   :distance_field_name => :distance

  validates :lat, uniqueness: { scope: [:lng] }, if: -> { lat.present? && lng.present? }
  
  has_and_belongs_to_many :achievements
  has_many :objective_progress

  validates_presence_of :required_count, :tagline, :base_points
  validates_numericality_of :base_points, :required_count

  enum kind: [ "LOCATION", "ACTION" ]

  # This allows us to have a start timestamp and an end timestamp
  # between which this objective can be completed. When achievements
  # where all objectives are time constrained between specific days,
  # hours, or months, 
  enum time_constraint: [
    "NONE",

    # Objective can be completed any day between
    # the months in the start / end timestamps
    "BETWEEN_TIMESTAMP_MONTHS",

    # Objective can be completed any day, but between
    # the hours in the timestamps
    "BETWEEN_TIMESTAMP_HOURS",

    # Objective can be completed any time between the
    # dates in the timestamp
    "BETWEEN_TIMESTAMP_DAYS",

    # Objective can be completed any time, any week,
    # between the weekdays in the timestamps
    "BETWEEN_TIMESTAMP_WEEKDAYS",

    # Objective can only be completed between the
    # given timestamps
    "BETWEEN_TIMESTAMP_EXACT",
  ]

  # Check if the user can unlock this objective
  # either by location parameters, or if no location
  # is provided and it has a count, return true
  #
  # @param [Hash] hash
  # @option hash :x
  # @option hash :y
  # @option hash :count
  # @return boolean
  def can_complete? (x: nil, y: nil, count: nil, time: nil)

    time ||= DateTime.now

    # Raise exception if the objective is time constrained and cannot be completed
    unless time_constraint == "NONE"
      case time_constraint
      when "BETWEEN_TIMESTAMP_MONTHS"
        if !(from_timestamp.month..to_timestamp.month).include?(time.month)
          raise OutsideTimeRangeException.new(
            "Objective can only be completed between #{from_timestamp.strftime("%B")}-#{to_timestamp.strftime("%B")}"
          ) 
        end
      when "BETWEEN_TIMESTAMP_HOURS"
        if !(from_timestamp.hour..to_timestamp.hour).include?(time.hour)
          raise OutsideTimeRangeException.new(
            "Objective can only be completed between #{from_timestamp.strftime("%H:00")}-#{to_timestamp.strftime("%H:00")}"
          ) 
        end
      when "BETWEEN_TIMESTAMP_DAYS"
        if !(from_timestamp.mday..to_timestamp.mday).include?(time.mday)
          raise OutsideTimeRangeException.new(
            "Objective can only be completed between #{from_timestamp.mday}-#{to_timestamp.mday} each month"
          ) 
        end
      when "BETWEEN_TIMESTAMP_WEEKDAYS"
        if !(from_timestamp.wday..to_timestamp.wday).include?(time.wday)
          raise OutsideTimeRangeException.new(
            "Objective can only be completed between #{from_timestamp.strftime("%A")}-#{to_timestamp.strftime("%A")}"
          ) 
        end
      when "BETWEEN_TIMESTAMP_EXACT"
        if !(from_timestamp..to_timestamp).include?(time)
          raise OutsideTimeRangeException.new(
            "Objective can only be completed between #{from_timestamp.strftime("%Y-%m-%d %H:%M")}-#{to_timestamp.strftime("%Y-%m-%d %H:%M")}"
          ) 
        end
      end
    end

    case kind
    when "LOCATION"
      raise TooFarAwayException.new("Invalid coordinates") if x.nil? or y.nil?
      distance = distance_to([x.to_f, y.to_f])
      raise TooFarAwayException.new("#{distance} is further away than minimum #{Settings.unlock_distance}") if (distance > Settings.unlock_distance)
      true
    when "ACTION"
      true
    else
      false
    end
  end

  # Complete the objective
  def complete(user: nil, x: nil, y: nil, time: nil)
    raise NoUserProvidedException.new if user.nil?
    can_complete?(x: x, y: y, time: time)

    # If the user already has some progress on this objective (i.e for repetition objectives)
    # then continue working with that.
    if progress = ObjectiveProgress.includes(:objective, :user).find_by(user: user, objective: self)
      puts "Objective progress existed, increasing count"
      if !required_count.nil? && progress.current_count < required_count
        progress.update_attributes(
          current_count: progress.current_count + 1,
          completed: (progress.current_count + 1) >= required_count,
        )
      end
    # Otherwise we'll create one
    else
      completed = true unless kind == "ACTION" && required_count > 1
      progress = ObjectiveProgress.create!(user: user, objective: self, completed: completed, current_count: 1)
    end

    # If the objective was completed, find all achievements
    # that may now be unlocked by the user

    progress
  end
end
