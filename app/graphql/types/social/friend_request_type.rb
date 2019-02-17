module Types
  module Social
    class FriendRequestType < Types::BaseObject
      implements Types::Interfaces::NotificationInterface
      description <<-DESC
Friend requests lets users add other users as their friends,
and the main purpose of this is so that when a user links
their account with a social network, if he/she allows us to
import their friends, we can find (or suggest) friends to
add.

We use a Friend-model rather than a Follow-model so that
if we were to display recently completed Achievements by
friends on the Home-screen, the user must have explicitly
accepted the people who would see their unlocked Achievements
in their feed; whereas with a Follow-model, anybody could
keep track of the physical whereabouts of anybody else, at
any given time. Even if we do not track anybody's location,
seeing that somebody unlocked an Achievement near e.g the
Eiffel tower 5 minutes ago, gives you a pretty good idea that
they must be somewhere around the Eiffel tower.

Because we consider this sensitive user information, users
must explicitly add, and accept, who is allowed to see when
they complete Achievements.
DESC
      field :id, ID, null: false
      field :message, String, null: false,
      description: "Add a message to the user you're sending a request to"

      field :is_accepted, Boolean, null: false,
      description: "Whether or not this request has been accepted"
      def is_accepted
        !!object.to.friends.exists?(id: object.user.id)
      end
      
      field :sender, UserType, null: false,
      description: "User who sent the request"
      def sender
        object.user
      end
      field :receiver, UserType, null: false,
      description: "User who will receive the request"
      def receiver
        object.to
      end
      
      field :created_at, Integer, null: false
      field :updated_at, Integer, null: false
    end
  end
end