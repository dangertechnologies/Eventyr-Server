# == Schema Information
#
# Table name: roles
#
#  id               :bigint(8)        not null, primary key
#  name             :string
#  description      :text
#  permission_level :integer
#  img_path         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Role < ApplicationRecord
  has_many :users
  validates_presence_of :name, :description

  validates :name, length: { minimum: 5, maximum: 50 }
  validates :description, length: { minimum: 5 }
end
