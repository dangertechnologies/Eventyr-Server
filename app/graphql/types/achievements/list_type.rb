module Types
  module Achievements
    class ListType < Types::BaseObject
      description <<-DESC
Lists are containers for Achievements, designed
to let users, or the community, curate collections
of Achievements to complete for special purposes. 
On a community scale, a List of Achievements could 
be something like "Winter is coming", and contain
a set of winter-specific Achievements to complete.

For users, it's important to be able to curate
their own lists, to easily be able to share a set
of custom Achievements to be completed with friends.
For example, if you were going on a hiking trip with
a group of friends, you may want to create a list
called *Hiking the Alps*, which could contain some
of the public Achievements in the alps, and maybe
some Achievements you've created yourself. Since
Achievements you've created yourself are only
accessible to the users you've shared it with,
putting them in a list and then sharing the list
is a quick and easy way to share multiple Achievements
and allow friends to complete non-public Achievements
together with you.
DESC
      field :id, ID, null: false
      field :title, String, null: false,
      description: "Name of the list"
      field :is_followed, Boolean, null: false,
      description: "Whether or not the user is following this list"
      def is_followed
        FollowedList.exists?(user_id: context[:current_user].id, list_id: object.id)
      end


      field :author, Social::UserType, null: false,
      description: "User who created this list"
      def author
        object.user
      end

      field :achievements_count, Integer, null: false,
      description: "Total number of Achievements available in list"
      def achievements_count
        object.list_content.count
      end

      field :coordinates, [[Float]], null: false, cache: true,
      description: "Coordinates for all objectives in all Achievements in list. This can be used to sort lists by distance (of the closest Achievement)"
      def coordinates
        Objective.joins(achievements: :lists).where(achievements: { lists: { id: object.id } }).pluck(:lat, :lng)
      end

      field :is_editable, Boolean, null: false
      def is_editable
        can? :update, object
      end

      field :is_public, Boolean, null: false,
      description: "Whether or not this list is available to everybody"

      field :achievements, AchievementType.connection_type, null: true,
      description: "Contents of the list. Can be updated by everybody the list has been shared with, and the author."
      def achievements
        Achievement.includes(:category, :objectives, :user).where(id: object.list_content.where.not(achievement_id: nil).pluck(:achievement_id))
      end
    end
  end
end