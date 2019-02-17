# == Schema Information
#
# Table name: notifications
#
#  id          :bigint(8)        not null, primary key
#  user_id     :bigint(8)
#  from_id     :bigint(8)
#  seen        :boolean
#  target_type :string
#  target_id   :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  kind        :integer
#
# Indexes
#
#  index_notifications_on_from_id                    (from_id)
#  index_notifications_on_target_type_and_target_id  (target_type,target_id)
#  index_notifications_on_user_id                    (user_id)
#

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :from, class_name: 'User', foreign_key: 'from_id'
  belongs_to :target, polymorphic: true
  
  
  enum kind: [
    :ACHIEVEMENT_UNLOCKED,
    :ACHIEVEMENT_UNLOCKED_COOP_BONUS,
    :COOPERATION_REQUEST_RECEIVED,
    :COOPERATION_REQUEST_ACCEPTED,
    :COOPERATION_REQUEST_REJECTED,
    :SHARED_ACHIEVEMENT_RECEIVED,
    :SHARED_LIST_RECEIVED,
    :FRIEND_REQUEST_RECEIVED,
    :FRIEND_REQUEST_ACCEPTED,
    :REWARD_UNLOCKED,
  ]
  
  after_create :transmit

  # Broadcast!
  def transmit
    EventyrSchema.subscriptions.trigger(
      "notificationReceived",
      {},
      Notification.find(id),
      scope: user.id
    )
  end
end
