module Types
  module Social
    class NotificationType < Types::BaseObject
      description <<-DESC
**IMPORTANT**: These are not necessarily PUSH notifications,
but notifications that may show up in a users "feed",
or in-app notification list.

A Notification could be anything like:
- "Annie has invited you to cooperate on View from the Top"
- "Claire sent you a friend request"
- "Achievement Unlocked: DoubleDutch Dinosaur Duplex in Dubai"
- "Dirk accepted your cooperation request."
- "Erin added a new item to your list Hiking the Pyrenees"
- "Fred unlocked Stormy Seas! +375 coop bonus"
- "Gerardo shared a List with you."

Some notifications may require an action from the user, and
some may just be informational. It's up to the client to decide
whether an action should be required of, or offered to the user.

If a notification involves another user, such as when the notification
is a FriendRequest, or CoopRequest, this user will be set as Notification.sender,
and the resource it concerns, e.g a CoopRequest, will be set as the
Notification.target

Messages displayed for notifications are up to the client, to allow
proper localization.
DESC
      field :id, ID, null: false
      field :kind, NotificationKindType, null: false
      field :receiver, UserType, null: false,
      description: "User receiving the notification"
      def receiver
        object.user_id ? Loaders::RecordLoader.for(::User).load(object.user_id) : nil
      end

      field :sender, UserType, null: true,
      description: "User sending the notification, if any"
      def sender
        object.from_id ? Loaders::RecordLoader.for(::User).load(object.from_id) : nil
      end
      
      field :target_type, String, null: false,
      description: "String representation of the target model, e.g CoopRequest, Unlocked, etc."
      field :target, Types::Interfaces::NotificationInterface, null: false,
      description: "Resource to perform additional actions upon, e.g a CoopRequest to accept/reject"
      def target
        case object.target_type
        when "CoopRequest"
          Loaders::RecordLoader.for(::CoopRequest).load(object.target_id)
        when "FriendRequest"
          Loaders::RecordLoader.for(::FriendRequest).load(object.target_id)
        when "SharedAchievement"
          Loaders::RecordLoader.for(::SharedAchievement).load(object.target_id)
        when "SharedList"
          Loaders::RecordLoader.for(::SharedList).load(object.target_id)
        else
          object.target
        end
      end

      field :seen, Boolean, null: false,
      description: "Whether or not the user has seen this notification. Will be set to `true` when the receiving user receives it."
      
      field :created_at, Integer, null: false
    end
  end
end