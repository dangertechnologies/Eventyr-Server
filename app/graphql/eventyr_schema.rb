require "graphql/batch"
require "graphql/cache"


class EventyrSchema < GraphQL::Schema
  use(GraphQL::Subscriptions::ActionCableSubscriptions)
  use(GraphQL::Backtrace)

  mutation(Types::MutationType)
  query(Types::QueryType)
  subscription(Types::Subscriptions::SubscriptionType)

  def self.resolve_type(type, obj, ctx)
    case obj
    when Achievement
      Types::Achievements::AchievementType
    when Objective
      Types::Achievements::ObjectiveType
    when User
      Types::Social::UserType
    when Location
      Types::Locations::LocationType
    else
      raise("Unexpected object: #{obj}")
    end
  end

  rescue_from ::ActionController::InvalidAuthenticityToken do
    "You're not logged in"
  end
  
  use(GraphQL::Batch)
  use(GraphQL::Cache)
end
