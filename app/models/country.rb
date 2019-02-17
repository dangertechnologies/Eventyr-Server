# == Schema Information
#
# Table name: countries
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  region_id  :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_region_id  (region_id)
#

class Country < ApplicationRecord
  belongs_to :region
  has_many :users

  has_many :achievements

  validates_presence_of :name
  validates :name, length: { minimum: 2, maximum: 255}
  validates_associated :region
  
  # TODO: This works really badly, because the coordinates arent right
  def self.from_location(lat: nil, lng: nil)
    ISO3166::Country.all.select { |c|
      box = Geokit::Bounds.new(
        Geokit::LatLng.new(
          c.min_latitude.to_f,
          c.min_longitude.to_f,
        ),
        Geokit::LatLng.new(
          c.max_latitude.to_f,
          c.max_longitude.to_f
        )
      )

      box.contains?([lat, lng])
    }.sort_by { |c| 
      Geokit::Bounds.new(
        Geokit::LatLng.new(
          c.min_latitude.to_f,
          c.min_longitude.to_f,
        ),
        Geokit::LatLng.new(
          c.max_latitude.to_f,
          c.max_longitude.to_f
        )
      ).center.distance_to([lat, lng])
    }
  end
end
