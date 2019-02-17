module Types
  module Locations
    class ContinentType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :regions, [RegionType], null: false
    end
  end
end
