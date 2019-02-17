module Types
  module Achievements
    class AchievementType < Types::BaseObject
      description <<-DESC
An Achievement is a collection of objectives
a user must complete before having "achieved"
something. When a user completes an Achievement,
the points awarded are based on which Achievement.category,
Achievement.kind, and Achievement.mode the Achievement
had, together with the sum of all its objective's points.

### Personal vs Global
Achievements may be personal, or global.
When a user creates a new Achievement,
this Achievement is always considered to be
/personal/. This means the Achievement
is only accessible to the user who created it,
and any users that it has been /shared/ with,
and so it will not show up in the normal Achievement
search queries, but must be queried for by ID,
or by searching specifically for a users "personal"
Achievements. 

### Voting
If a user wishes to make his / her Achievement
globally accessible to everybody, he/she may set
the flag Achievement.is_suggested_global.
This allows the Achievement to show up as a community
Achievement, and enables it to receive upvotes,
or downvotes (check the mutations).

It's yet to be decided what the threshold for
upvotes/downvotes should be before an Achievement
is made global, but it should probably be a few hundred
upvotes, and a ratio of upvotes:downvotes of more than 3:1.
DESC
      field :id, ID, null: false
      field :name, String, null: false, cache: true
      field :expires, Integer, null: true, cache: true
      field :in_lists, [Achievements::ListType], null: false, cache: false,
      description: "User's lists that contain this Achievement"
      def in_lists
        ::List.where(id: ::ListContent.includes(:list).where(achievement_id: object.id, lists: { user_id: context[:current_user].id}).pluck(:list_id))
      end


      field :upvotes, Integer, null: false
      def upvotes
        object.upvotes || 0
      end

      field :downvotes, Integer, null: false
      def downvotes
        object.downvotes || 0
      end

      field :is_global, Boolean, null: false, cache: true,
      description: 'Whether or not the Achievement is available to everybody'

      def is_global
        !!object.is_global
      end
      field :is_suggested_global, Boolean, null: false,
      description: 'Has the owner suggested this Achievement to be evaluated by the community?'

      def is_suggested_global
        !!object.is_suggested_global
      end

      field :cooperation_users, [Types::Social::UserType], null: true,
      description: 'Other users the user is currently cooperating with on this Achievement'
      def cooperation_users
        ::User.where(
          id: ::CoopRequest.where(
                user: context[:current_user],
                achievement_id: object.id
              ).or(
                ::CoopRequest.where(target: context[:current_user], achievement_id: object.id)
              ).where(pending: false).pluck(:user_id, :target_id).flatten
        ).where.not(id: context[:current_user].id)
      end

      field :has_parents, Boolean, null: false,
      description: 'Does this Achievement depend on other Achievements? (BETA)'
      field :is_multi_player, Boolean, null: false, cache: true,
      description: 'Does this Achievement allow users to complete it as a group? Default: true'

      def is_multi_player
        !!object.is_multiplayer
      end

      field :short_description, String, null: false, cache: true,
      description: 'Ellipsized first 100 characters of the description, before the first newline'
      field :full_description, String, null: true,
      description: 'Entire description. This may be very long.'
      field :base_points, Integer, null: false, cache: true,
      description: 'Achievements may have additional basePoints used to calculate Achievement.points'

      field :author, Social::UserType, null: false,
      description: 'User who created the Achievement'

      def author
        Loaders::RecordLoader.for(::User).load(object.user_id)
      end

      field :objectives, [Achievements::ObjectiveType], null: false, cache: true,
      description: 'All linked Objectives. Objectives may belong to multiple Achievements.'

      field :icon, Types::Assets::IconType, null: false, cache: true,
      description: 'An icon from the specified subset of MaterialCommunityIcons'

      field :mode, Types::Taxonomy::ModeType, null: false, cache: true,
      description: "Difficulty. One of: %s" % Achievement.modes.keys.sort.map(&:to_s).join(", ")

      field :kind, Types::Taxonomy::KindType, null: false, cache: true,
      description: "Achievement type, e.g %s" % Achievement.kinds.keys.sort.map(&:to_s).join(", ")

      field :unlocked, Boolean, null: false,
      description: "Whether or not the user has unlocked this Achievement"
      def unlocked
        Unlocked.exists?(user: context[:current_user], achievement_id: object.id)
      end


      field :points, Float, null: false, cache: true,
      description: 'Calculated points awarded for completing the Achievement'
      def points
        object.calculated_points
      end

      field :category, Taxonomy::CategoryType, null: false, cache: true,
      description: 'Category the Achievement belongs to, e.g Food & Culinary, Culture, etc.'
    end
  end
end