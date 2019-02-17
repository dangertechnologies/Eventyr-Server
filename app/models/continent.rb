# == Schema Information
#
# Table name: continents
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Continent < ApplicationRecord
	has_many :regions
	validates_presence_of :name
	validates :name, length: {minimum: 4, maximum: 255}
end
