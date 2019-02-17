module Types
  module Interfaces
    module NotificationInterface
      include Types::BaseInterface

      field :id, ID, null: false

      definition_methods do
        # Determine what object type to use for `object`
        def resolve_type(object, context)
          if object.is_a?(::Achievement)
            Types::Achievements::AchievementType
          elsif object.is_a?(::List)
            Types::Achievements::ListType
          elsif object.is_a?(::User)
            Types::Social::UserType
          elsif object.is_a?(::CoopRequest)
            Types::Social::CoopRequestType
          elsif object.is_a?(FriendRequest)
            Types::Social::FriendRequestType
          elsif object.is_a?(::SharedList)
            Types::Social::SharedListType
          elsif object.is_a?(::SharedAchievement)
            Types::Social::SharedAchievementType
          elsif object.is_a?(::Unlocked)
            Types::Achievements::UnlockedType
          else
            raise "Unexpected Notification resource: #{object.inspect}"
          end
        end
      end
    end
  end
end