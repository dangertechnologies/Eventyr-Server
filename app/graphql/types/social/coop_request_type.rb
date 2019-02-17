module Types
  module Social
    class CoopRequestType < Types::BaseObject
      description <<-DESC
Cooperation Requests can be sent from any Achievement,
to any other user in the area, to ask whether or not they
would like to meet up and complete the Achievement together.
When a CoopRequest is sent, the user may receive a notification
like 'Annie has invited you to complete an Achievement',
and once the other party has accepted the invitation, both users
are now in *coop mode* for this Achievement, and will receive
bonus points for completing it.

Cooperation Requests can also be sent for *lists*, which binds
users to receive a coop bonus for any of the Achievements in the
list, provided they complete the Achievement within 5 minutes of
eachother. It doesn't matter if one of the users is without internet
connection or not, because as soon as he/she connects and unlocks
the Achievement, both will be awarded bonus points.

### Bonus calculation
Coop bonus is calculated as: `Achievement.points * 0.8^N`,
where N is the amount of times users have cooperated together
before, but never goes below 3. This means that each time you
complete an Achievement with somebody, you get +80% extra points,
and the next time you complete an Achievement with the same person,
you get 80% of those 80% extra points, and so on. This causes
*diminishing returns*, where it will **always** be beneficial
for you to complete Achievements with other people, but it will
always be *more* beneficial to complete Achievements with new people.

### Groups
Lets say Annie and her boyfriend Barry always go together, but have
decided to meet up with a new third person, Claire. 
If the user is in multiplayer/cooperation mode with **several** users,
the coop bonus **does not compound**. Annie **will not** receive +80%
for cooperating with Claire and another bonus for Barry. 
Instead, the users **always gets the highest coop bonus available to them**.

This incentivizes inviting new people, because even if you always
unlock Achievements with a friend, inviting at least one new person
everytime, ensures everybody gets an additional 80% extra points.

### Practicality
TODO: When a user accepts a CoopRequest, we should perhaps provide a
time and location for them to meet up, but without knowing either users
location, this is difficult. Instead, we may need to introduce a way for
users to either a) message eachother or b) agree on a meetup point.
DESC

      implements Types::Interfaces::NotificationInterface
      field :id, ID, null: false
      field :sender, UserType, null: false,
      description: 'User who sent this request'

      field :message, String, null: false,
      description: 'Message to the receiver'
      def message
        object.message || ""
      end

      def sender
        object.user_id ? Loaders::RecordLoader.for(::User).load(object.user_id) : nil
      end

      field :receiver, UserType, null: false,
      description: 'User who received this request'
      def receiver
        object.target_id ? Loaders::RecordLoader.for(::User).load(object.target_id) : nil
      end

      field :achievement, Achievements::AchievementType, null: true,
      description: 'Achievement the coop request applies to. May be null if a list is given'
      def achievement
        object.achievement_id ? Loaders::RecordLoader.for(::Achievement).load(object.achievement_id) : nil
      end

      field :list, Achievements::ListType, null: true,
      description: 'List the coop request applies to. May be null if an Achievement is given.'
      def list
        object.achievement_id ? Loaders::RecordLoader.for(::List).load(object.list_id) : nil
      end

      field :is_pending, Boolean, null: false,
      description: 'CoopRequest is pending until the receiving user accepts it'
      def is_pending
        !!object.pending
      end

      field :is_accepted, Boolean, null: false,
      description: 'Has the receiving user accepted the request?'
      def is_accepted
        object.pending == false
      end

      field :is_complete, Boolean, null: false,
      description: 'When the request is accepted, and the objective has been completed for both users, this will be true'
      def is_complete
        !!object.complete
      end
      
      field :created_at, Integer, null: false
      field :updated_at, Integer, null: false
    end
  end
end