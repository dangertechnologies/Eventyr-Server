module Types
  module Locations
    class RegionType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false

      field :continent, ContinentType, null: false
      field :countries, [CountryType], null: false
    end
  end
end