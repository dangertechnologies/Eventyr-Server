module Types
  module Achievements
    class UnlockedType < Types::BaseObject
      description <<-DESC
When an Achievement becomes **Unlocked**, a container is created
for it which adds metadata, e.g how many points were awarded for
completing this Achievement, and whether or not any cooperation
bonus points were awarded.

This is used so that, for example, if two users are in multiplayer/coop
mode, and one of them is offline, the user who is online will
receive no coop bonus until the offline user goes online. When the
offline user goes online, and the Achievement becomes Unlocked
with a given timestamp for that user, both of their Unlocked
Achievement will be updated with the given coop bonus provided
they both unlocked the Achievement within 5 minutes of each other.
DESC
      implements Types::Interfaces::NotificationInterface
      field :id, ID, null: false
      field :achievement, AchievementType, null: false


      field :points, Float, null: false,
      description: "Poins awarded for completing the Achievement, usually equals Achievement.points"
      field :coop, Boolean, null: false,
      description: "Whether or not this Achievement was completed as multiplayer / coop"
      def coop
        object.coop == true
      end

      field :coop_bonus, Float, null: false,
      description: "Additional bonus points for completing the Achievement with another user. This field will be 0 until any other users in the groups also complete the Achievement"
      
      field :repetition_count, Integer, null: false,
      description: "How many times a user has unlocked the same Achievement, if the Achievement can be done multiple times"

      field :user, Social::UserType, null: false,
      description: "User who unlocked this Achievement"

      field :created_at, Integer, null: false
    end
  end
end
