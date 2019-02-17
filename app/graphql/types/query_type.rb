module Types
  class QueryType < Types::BaseQuery

    requires_authentication :current_user,
                            :achievement,
                            :user,
                            :users,
                            :notifications,
                            :achievements,
                            :friends,
                            :followed_lists

    ##
    ### Searching for Achievements
    ##
    field :achievements, Achievements::AchievementType.connection_type, null: false do
      argument :type, String, required: false, default_value: "ALL",
      description: "ALL (public), SUGGESTED (users suggested achievements), COMMUNITY, or PERSONAL (users created achievements)"
      argument :list_id, String, required: false,
      description: "Fetch all Achievements belonging to a list"
      argument :near, [Float], required: false,
      description: "Provide [latitude,longitude] to search for achievements in that area"
      argument :category, Integer, required: false,
      description: "Allows you to filter by category ID"
      argument :kind, Types::Taxonomy::KindType, required: false
      argument :mode, Types::Taxonomy::ModeType, required: false
      argument :multiplayer, Boolean, required: false,
      description: "Whether or not to only show multiplayer Achievements"
      argument :coordinates, [Float], required: false,
      description: "Order by distance from these coordinates"
    end

    def achievements(
      near: nil,
      category: nil,
      kind: nil,
      mode: nil,
      multiplayer: nil,
      type: nil,
      coordinates: nil,
      list_id: nil
    )

      query_base = ::Achievement.joins(:objectives).includes(:category)
      if list_id
        query_base.where(id: ::ListContent.where(list_id: list_id).pluck(:achievement_id))
      else
        case (type || "").downcase
        when "all"
          query = query_base.where(is_global: true)
          query = query.or(query_base.where(user: context[:current_user])) if logged_in?
        when "community"
          query = query_base.where(is_suggested_global: true)
        when "suggested"
          authenticate!
          query = query_base.where(
            id: ::Tracked.includes(:achievement).where(user: context[:current_user]).collect(&:id)
          )
        when "personal"
          authenticate!
          query = query_base.where(user: context[:current_user])
        else
          query = query_base.where(is_global: true).or(
            query_base.where(user: context[:current_user])
          )
        end
        query = query.where(category_id: category) if category
        query = query.where(mode: mode) if mode
        query = query.where(kind: kind) if kind

        query = query.by_distance(origin: coordinates) if coordinates
        
        query = query.uniq
        # Preload all objectives
        
        Loaders::RecordLoader.for(::Objective).load_many(
          Objective.includes(:achievements).where(achievements: { id: query.collect(&:id) }).pluck(:id)
        )
        
        query
      end
    end

    ##
    ### For maps, it makes more sense to find by objectives
    ##
    field :objectives, Achievements::ObjectiveType.connection_type, null: false, cache: { expiry: 120 } do
      argument :near, [Float], required: false,
      description: "Provide [latitude,longitude] to search for objectives in that area"
    end
    def objectives(near: nil)
      ::Objective.includes(achievements: [:category]).within(5, origin: near).where(achievements: { user: context[:current_user]}).or(
        ::Objective.includes(achievements: [:category]).within(5, origin: near).where(achievements: { is_global: true})
      )
    end

    ##
    ### Find a single achievement
    ##

    field :achievement, Achievements::AchievementType, null: true do
      argument :id, String, required: true
    end

    def achievement(id: nil)
      ::Achievement.includes(:objectives, :category).where(is_global: true).or(
        ::Achievement.includes(:objectives, :category).where(user: context[:current_user])
      ).find(id.to_i)
    end

    ##
    ### Lists
    ##
    field :lists, Achievements::ListType.connection_type, null: false, cache: false do
      argument :user_id, String, required: false
      argument :near, [Float], required: false,
      description: "Find lists with Achievements in the nearby area. This can be used to show lists in the feed"
      argument :type, String, required: false,
      description: "Used to determine what kind of Achievements to search for, same as the type field on Achievements"
    end

    def lists(user_id: nil, near: nil, type: nil)
      if user_id
        # TODO: This should possibly also return lists the user is 
        # following, or that has been shared with the user. These
        # should be displayed with a badge indicating so in the app
        base_query = ::List.includes(achievements: [:category, :objectives])

        base_query.where(user_id: user_id)
      else
        base_query = ::List.includes(:list_content, achievements: [:category, :objectives])
        base_query = base_query.where(is_public: true).or(base_query.where(user: context[:current_user])).or(base_query.where(id: FollowedList.where(user: context[:current_user]).pluck(:list_id)))
        if near
          base_query.where(list_contents: { achievement: achievements(coordinates: near, type: type) })
        else 
          base_query
        end
      end
    end


    field :followed_lists, Achievements::ListType.connection_type, null: false, cache: false
    def followed_lists(near: nil, type: nil)
      base_query = ::List.includes(achievements: [:category, :objectives])
      base_query.where(id: FollowedList.where(user: context[:current_user]).pluck(:list_id))
    end

    ##
    ### Organizational data for Types, Categories, Modes,
    ### Countries, Regions, etc
    ##

    field :continents, Locations::ContinentType.connection_type, null: false, cache: { expiry: 86400 } do
      argument :search, String, required: false
    end

    def continents(search: nil)
      ::Continent.all
    end

    field :regions, Locations::RegionType.connection_type, null: false, cache: { expiry: 86400 } do
      argument :search, String, required: false
    end

    def regions(search: nil)
      ::Region.all
    end

    field :countries, Locations::CountryType.connection_type, null: false, cache: { expiry: 86400 } do
      argument :search, String, required: false
    end

    def countries(search: nil)
      ::Country.all
    end

    field :modes, [Types::Taxonomy::ModeType], null: false, cache: { expiry: 86400 },
    description: "Fetch all existing modes an Achievement may have"

    def modes(search: nil)
      ::Achievement.modes.keys.sort
    end

    field :kinds, [Types::Taxonomy::KindType], null: false, cache: { expiry: 86400 },
    description: "Fetch all existing kinds of Achievements"

    def kinds(search: nil)
      ::Achievement.kinds.keys.sort
    end

    field :categories, Taxonomy::CategoryType.connection_type, null: false, cache: { expiry: 86400 },
    description: "Fetch all existing Categories"

    def categories(search: nil)
      ::Category.all
    end

    field :icons, [Types::Assets::IconType], null: false,
    description: "Get a list of all supported icons"

    def icons(search: nil)
      ::Achievement.icons.keys.sort
    end

    ##
    ### Current User
    ###
    field :current_user, Social::UserType, null: false,
    description: "Always returns the currently logged in user. Requires authentication."
    def current_user
      context[:current_user]
    end

    ##
    ### User search
    ##
    field :users, Social::UserType.connection_type, null: false,
    description: "Find users currently working on the same achievements, or search for users by name or email. At least one argument is required." do
      argument :achievement_id, String, required: false,
      description: "Find users currently working on this Achievement"

      argument :search, String, required: false,
      description: "Search for users by email or name. The match must be /exact/, for privacy reasons."

    end
    def users(achievement_id: nil, search: nil)
      if !achievement_id.nil?
        ::User.includes(:tracked).where(trackeds: { achievement_id: achievement_id })
      elsif !search.nil?
        ::User.where(name: search).or(
          ::User.where(email: search)
        )
      end
    end

    ##
    ### Friends
    ##
    field :friends, Social::UserType.connection_type, null: false,
    description: "Find friends of current user" do
      argument :search, String, required: false,
      description: 'Search for users matching exact email or name'
    end
    def friends(search: nil)
      query = ::User.where(id: context[:current_user].friends.pluck(:id))
      query = query.or(::User.where(name: search)).or(::User.where(email: search)) if search
      query
    end

    field :user, Social::UserType, null: false,
    description: "Fetch another users data. This requires authentication." do
      argument :id, String, required: true
    end
    def user(id: nil)
      user = ::User.includes(:role, unlocked: :achievement).find(id.to_i)
      authorize! :view, user
      user
    end

    field :notifications, Social::NotificationType.connection_type, null: false,
    description: "Notifications received by the user", cache: false
    def notifications
      # Preload coop requests and friend requests:
      notifications = context[:current_user].notifications.order(created_at: :desc)

      Promise.all([
        Loaders::RecordLoader.for(::CoopRequest).load(notifications.select{ |n| n.target_type == "CoopRequest" }.collect(&:target_id)),
        Loaders::RecordLoader.for(::FriendRequest).load(notifications.select{ |n| n.target_type == "FriendRequest" }.collect(&:target_id))
      ]).then do
        notifications
      end
    end
  end
end
