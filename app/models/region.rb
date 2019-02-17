# == Schema Information
#
# Table name: regions
#
#  id           :bigint(8)        not null, primary key
#  name         :string
#  continent_id :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_regions_on_continent_id  (continent_id)
#

class Region < ApplicationRecord
  belongs_to :continent
  has_many :countries

  validates_presence_of :name, :continent
  validates :name, length: { minimum: 2, maximum: 255 }
end
