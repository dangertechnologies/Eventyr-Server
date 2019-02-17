# == Schema Information
#
# Table name: shared_achievements
#
#  id             :bigint(8)        not null, primary key
#  achievement_id :bigint(8)
#  user_id        :bigint(8)
#  request_coop   :boolean
#  can_invite     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  target_id      :integer
#
# Indexes
#
#  index_shared_achievements_on_achievement_id  (achievement_id)
#  index_shared_achievements_on_target_id       (target_id)
#  index_shared_achievements_on_user_id         (user_id)
#

class SharedAchievement < ApplicationRecord
  belongs_to :achievement
  belongs_to :user
  belongs_to :target, :class_name => 'User'
  has_many :notifications, as: :target, dependent: :delete_all
  validates_presence_of :user, :target, :achievement
  validates_associated :user
  validates_associated :achievement

  after_create :notify_request

  # Notify the target user about this
  def notify_request
    ::Notification.create!(
      from: user,
      user_id: target_id,
      seen: false,
      target: self,
      kind: :SHARED_ACHIEVEMENT_RECEIVED
    )
  end
end
