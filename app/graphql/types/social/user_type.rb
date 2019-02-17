module Types
  module Social
    class UserType < Types::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :email, String, null: false
      field :points, Float, null: false
      field :personal_points, Float, null: false
      field :role, Taxonomy::RoleType, null: false
      field :avatar, String, null: true, cache: true

      field :allow_coop, Boolean, null: false, cache: false

      def allow_coop
        !!object.allow_coop
      end

      def avatar
        object.avatar ? "/assets/avatar/#{object.avatar_url}" : nil
      end

      field :country, Locations::CountryType, null: false
      field :unlocked_achievements, Achievements::UnlockedType.connection_type, null: false,
      description: "All Achievements unlocked by the user"
      field :user_achievements, Achievements::AchievementType.connection_type, null: false,
      description: "All Achievements created by the user"

      field :lists, Achievements::ListType.connection_type, null: false,
      description: "User's created lists"

      field :coop_points, Integer, null: false
      def coop_points
        object.unlocked.sum(:coop_bonus)
      end

      field :unlocked_count, Integer, null: false
      def unlocked_count
        object.unlocked.count
      end

      field :is_friend, Boolean, null: false
      def is_friend
        context[:current_user].friends.include?(object)
      end

      field :is_pending_friend, Boolean, null: false
      def is_pending_friend
        ::FriendRequest.exists?(user: context[:current_user], to: object) && !context[:current_user].friends.include?(object)
      end

      def user_achievements
        # TODO: This should only search for achievements with request review
        ::Achievement.joins(:objectives, :category).where(user: object).distinct
      end

      def unlocked_achievements
        object.unlocked.includes(achievement: [:objectives, :category])
      end

      def name
        object.name || "Nameless"
      end

    end
  end
end
