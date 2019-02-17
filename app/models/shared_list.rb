# == Schema Information
#
# Table name: shared_lists
#
#  id               :bigint(8)        not null, primary key
#  list_id          :bigint(8)
#  user_id          :bigint(8)
#  request_coop     :boolean
#  can_invite       :boolean
#  is_collaborative :boolean
#  target_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_shared_lists_on_list_id    (list_id)
#  index_shared_lists_on_target_id  (target_id)
#  index_shared_lists_on_user_id    (user_id)
#

class SharedList < ApplicationRecord
  belongs_to :list
  belongs_to :user
  belongs_to :target, class_name: 'User'
  has_many :notifications, as: :target, dependent: :delete_all

  validates_presence_of :list, :user, :target

  validates_associated :user
  validates_associated :target
  validates_associated :list

  after_create :notify_request

  # Notify the target user about this
  def notify_request
    ::Notification.create!(
      from: user,
      user_id: target_id,
      seen: false,
      target: self,
      kind: :SHARED_LIST_RECEIVED
    )
  end
end
