module Types
  module Taxonomy
    class CategoryType < Types::BaseObject
      field :id, ID, null: false
      field :title, String, null: false
      field :icon, String, null: false
      field :points, Integer, null: false

    end
  end
end