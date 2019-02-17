module Types
  class BaseObject < GraphQL::Schema::Object
    include CanCan::ControllerAdditions
    field_class GraphQL::Cache::Field

    def logged_in?
      !context[:current_user].nil?
    end

    def current_user
      context[:current_user]
    end
  end
end
