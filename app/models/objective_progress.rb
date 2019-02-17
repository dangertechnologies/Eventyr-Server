# == Schema Information
#
# Table name: objective_progresses
#
#  id            :bigint(8)        not null, primary key
#  user_id       :bigint(8)
#  objective_id  :bigint(8)
#  completed     :boolean
#  current_count :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_objective_progresses_on_objective_id  (objective_id)
#  index_objective_progresses_on_user_id       (user_id)
#

class ObjectiveProgress < ApplicationRecord
  belongs_to :user
  belongs_to :objective

  validates_presence_of :current_count, :completed, :objective, :user
  validates_numericality_of :current_count
end
