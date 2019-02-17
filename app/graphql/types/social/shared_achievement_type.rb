module Types
  module Social
    class SharedAchievementType < Types::BaseObject
      implements Types::Interfaces::NotificationInterface
      description <<-DESC
Shared Achievements are achievements that a user have sent
to another user. These can be any Achievement that the user
has found in his feed, or list, or even on another users profile,
and wanted to recommend somebody else; or it could be an
Achievement the user has created which is not public, but that
he or she wants a friend to be able to complete.
DESC
      field :id, ID, null: false
      field :achievement, Achievements::AchievementType, null: false,
      description: "The Achievement that's being shared"
      field :created_at, Integer, null: false

      field :sender, UserType, null: false,
      description: "User who shared the Achievement"
      def sender
        Loaders::RecordLoader.for(::User).load(object.user_id)
      end

      field :receiver, UserType, null: false,
      description: "User who received the shared Achievement"
      def receiver
        Loaders::RecordLoader.for(::User).load(object.target_id)
      end

      field :request_multi_player, Boolean, null: false,
      description: "Whether the user would like to cooperate on this. TODO: This should be a coop_request_id"
      def request_multi_player
        object.request_coop
      end

      field :is_invitable, Boolean, null: false,
      description: "This indicates whether or not the receiving user is allowed to invite others to cooperate"
      def is_invitable
        object.can_invite
      end
    end
  end
end