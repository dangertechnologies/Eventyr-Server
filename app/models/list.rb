# == Schema Information
#
# Table name: lists
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  user_id    :bigint(8)
#  is_public  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_lists_on_title    (to_tsvector('english'::regconfig, (title)::text)) USING gin
#  index_lists_on_user_id  (user_id)
#

class List < ApplicationRecord
  belongs_to :user
  has_many :shared_list
  has_many :list_content
  has_many :achievements, through: :list_content
  has_many :users, through: :shared_list

  validates :title, length: { minimum: 1, maximum: 255 }

end
