# == Schema Information
#
# Table name: unlockeds
#
#  id              :bigint(8)        not null, primary key
#  points          :integer
#  coop_bonus      :integer
#  user_id         :bigint(8)
#  achievement_id  :bigint(8)
#  coop            :boolean
#  verification_id :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_unlockeds_on_achievement_id   (achievement_id)
#  index_unlockeds_on_user_id          (user_id)
#  index_unlockeds_on_verification_id  (verification_id)
#

class Unlocked < ApplicationRecord
  belongs_to :user
  belongs_to :achievement
  has_one :title, through: :achievement
  has_many :verification
  has_many :notifications, as: :target, dependent: :delete_all
  delegate :name, :short_description, :calculated_points, prefix: true, to: :achievement

  validates_associated :user
  validates_associated :achievement

  validates_presence_of :user, :achievement

  after_create :notify_unlocked
  after_update :notify_coop

  # Create a notification for the user when an Achievement has been unlocked.
  # This does not need to be shown in the app, as the app should handle
  # local PUSH notifications itself.
  def notify_unlocked
    ::Notification.create!(
      from: user,
      user_id: user_id,
      seen: false,
      target: self,
      kind: :ACHIEVEMENT_UNLOCKED
    )
  end

  def notify_coop
    if saved_changes_to_coop_bonus?
    #  ::Notification.create!(
    #    from: user,
    #    user_id: user_id,
    #    seen: false,
    #    target: self,
    #    kind: :ACHIEVEMENT_UNLOCKED_COOP_BONUS
    #  )
    end
  end

end
