# == Schema Information
#
# Table name: followed_lists
#
#  id         :bigint(8)        not null, primary key
#  list_id    :bigint(8)
#  user_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_followed_lists_on_list_id  (list_id)
#  index_followed_lists_on_user_id  (user_id)
#

class FollowedList < ApplicationRecord
  belongs_to :list
  belongs_to :user
end
