# == Schema Information
#
# Table name: friend_requests
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  to_id      :bigint(8)
#  message    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_friend_requests_on_to_id    (to_id)
#  index_friend_requests_on_user_id  (user_id)
#

class FriendRequest < ApplicationRecord
  belongs_to :user
  belongs_to :to, class_name: "User", foreign_key: "to_id"
  has_many :notifications, as: :target, dependent: :delete_all
  validates_presence_of :user, :to

  after_create :notify_request

  # Notify the target user about this
  def notify_request
    ::Notification.create!(
      from: user,
      user_id: to_id,
      seen: false,
      target: self,
      kind: :FRIEND_REQUEST_RECEIVED
    )
  end
end
