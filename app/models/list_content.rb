# == Schema Information
#
# Table name: list_contents
#
#  id             :bigint(8)        not null, primary key
#  list_id        :bigint(8)
#  achievement_id :bigint(8)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_list_contents_on_achievement_id  (achievement_id)
#  index_list_contents_on_list_id         (list_id)
#

class ListContent < ApplicationRecord
  belongs_to :list
  belongs_to :achievement

  validates_uniqueness_of :list_id, scope: :achievement_id
  validates_associated :list
  validates_associated :achievement
end
