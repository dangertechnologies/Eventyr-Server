# == Schema Information
#
# Table name: trackeds
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)
#  achievement_id :bigint(8)
#  pinned         :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_trackeds_on_achievement_id  (achievement_id)
#  index_trackeds_on_user_id         (user_id)
#

class Tracked < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
  delegate :name, :calculate_points, :short_description, :full_description, to: :achievement, prefix: true
  delegate :name, :points, :personal_points, to: :user, prefix: true

  validates_associated :user
  validates_associated :achievement
  validates_uniqueness_of :achievement_id, scope: :user_id
  validates :pinned, inclusion: { in: [true, false] }
end
