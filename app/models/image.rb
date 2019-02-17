# == Schema Information
#
# Table name: images
#
#  id              :bigint(8)        not null, primary key
#  path            :string
#  resource_type   :string
#  resource_id     :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  profile_picture :boolean
#
# Indexes
#
#  index_images_on_resource_type_and_resource_id  (resource_type,resource_id)
#

class Image < ApplicationRecord
  #belongs_to :resource, polymorphic: true
end
