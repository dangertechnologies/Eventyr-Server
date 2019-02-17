# == Schema Information
#
# Table name: categories
#
#  id          :bigint(8)        not null, primary key
#  category_id :integer
#  description :text
#  icon        :integer
#  points      :integer
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_categories_on_icon   (icon)
#  index_categories_on_title  (title) UNIQUE
#

class Category < ApplicationRecord
  has_many :achievements
  include HasIcon       # It comes with an icon as wellbelongs_to :icon

  validates_presence_of :description, :points, :title, :icon
  validates :points, numericality: true
  validates :title, length: { minimum: 4, maximum: 255 }
  validates :description, length: { minimum: 5 }
end
