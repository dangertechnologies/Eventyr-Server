# == Schema Information
#
# Table name: votes
#
#  id             :bigint(8)        not null, primary key
#  achievement_id :bigint(8)
#  user_id        :bigint(8)
#  value          :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_votes_on_achievement_id  (achievement_id)
#  index_votes_on_user_id         (user_id)
#

class Vote < ApplicationRecord
  belongs_to :achievement
  belongs_to :user
  after_create :add_points
  after_save :update_points

  # Automatically add points to the achievement
  # for faster querying
  def add_points
    if value > 0
      achievement.update_attributes(
        upvotes: achievement.upvotes + 1,
        downvotes: achievement.upvotes - 1,
      )
    else
      achievement.update_attributes(
        upvotes: achievement.upvotes - 1,
        downvotes: achievement.upvotes + 1,
      )
    end
  end

  # Automatically update points on the achievement
  # if the user changes his/her vote
  def update_points
    return unless saved_change_to_value?
    old_value, new_value = saved_change_to_value

    if new_value > 0
      achievement.update_attributes(
        upvotes: achievement.upvotes + 1,
        downvotes: achievement.upvotes - 1,
      )
    else
      achievement.update_attributes(
        upvotes: achievement.upvotes - 1,
        downvotes: achievement.upvotes + 1,
      )
    end
  end
end
