# == Schema Information
#
# Table name: achievement_dependencies
#
#  id             :bigint(8)        not null, primary key
#  achievement_id :bigint(8)
#  dependency     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_achievement_dependencies_on_achievement_id  (achievement_id)
#

class AchievementDependency < ApplicationRecord
  belongs_to :achievement
  belongs_to :dependency, class_name: 'Achievement'
  validates_associated :achievement
end
