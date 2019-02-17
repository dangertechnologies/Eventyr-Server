module Types
  module Locations
    class CountryType < Types::BaseObject
      field :id, ID, null: false
      field :region, RegionType, null: false
      field :name, String, null: false
    end
  end
end
