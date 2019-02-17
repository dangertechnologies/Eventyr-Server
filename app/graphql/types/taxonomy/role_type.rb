module Types
  module Taxonomy
    
    class RoleType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :permission_level, String, null: false

      field :users, [Social::UserType], null: true

      field :created_at, Integer, null: false
    end
  end
end