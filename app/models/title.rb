# == Schema Information
#
# Table name: titles
#
#  id             :bigint(8)        not null, primary key
#  name           :string
#  achievement_id :bigint(8)
#  points         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_titles_on_achievement_id  (achievement_id)
#

class Title < ApplicationRecord
  belongs_to :achievement

  has_many :unlocked, through: :achievement
  has_many :users, through: :unlocked

end
