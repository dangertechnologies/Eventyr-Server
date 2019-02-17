# == Schema Information
#
# Table name: coop_requests
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)
#  target_id      :bigint(8)
#  achievement_id :bigint(8)
#  list_id        :bigint(8)
#  pending        :boolean
#  complete       :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  message        :string
#
# Indexes
#
#  index_coop_requests_on_achievement_id  (achievement_id)
#  index_coop_requests_on_list_id         (list_id)
#  index_coop_requests_on_target_id       (target_id)
#  index_coop_requests_on_user_id         (user_id)
#

class CoopRequest < ApplicationRecord
  belongs_to :user
  belongs_to :target, class_name: 'User', foreign_key: 'target_id'
  belongs_to :achievement, optional: true
  belongs_to :list, optional: true
  has_many :notifications, as: :target, dependent: :delete_all

  after_create :notify_request
  after_update :notify_changed

  def notify_request
    # Successful creation, return the created object with no errors
    # Notify the target user about this
    ::Notification.create!(
      from: user,
      user_id: target_id,
      seen: false,
      target: self,
      kind: :COOPERATION_REQUEST_RECEIVED
    )
  end

  def notify_changed
    if saved_change_to_pending?
       
    elsif saved_change_to_complete?

    end
  end
end
