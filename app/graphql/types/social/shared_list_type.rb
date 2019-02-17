module Types
  module Social
    class SharedListType < Types::BaseObject
      implements Types::Interfaces::NotificationInterface
      description <<-DESC
Shared Lists are lists that a user have sent
to another user. These can be any List that the user
has found in his feed, or even on another users profile,
and wanted to recommend somebody else; or it could be a
List the user has created which is not public, but that
he or she wants a friend to be able to complete.

A user may create a List for a backpacking trip the user
is going on with a couple of friends, but without making
the list public, it wouldn't be possible for other users
to view the list.

Instead, the user may share the list with their group of
friends, and they would be able to view the Achievements
in the list, even if these achievements aren't public.
This way, users can make collaborative lists.
DESC
      field :id, ID, null: false
      field :list, Achievements::ListType, null: false,
      description: "List that's being shared"
      field :sender, UserType, null: false,
      description: "User who shared the List"
      def sender
        object.user
      end

      field :receiver, UserType, null: false,
      description: "User who receives the list"
      def receiver
        object.target
      end

      field :request_multi_player, Boolean, null: false,
      description: "Whether the user would like to cooperate on this. TODO: This should be a coop_request_id"
      def request_multi_player
        object.request_coop
      end

      field :is_invitable, Boolean, null: false
      def is_invitable
        object.can_invite
      end
    end
  end
end