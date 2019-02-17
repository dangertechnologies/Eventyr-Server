class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(role: Role.new(permission_level: 100))

    alias_action :new, :create, to: :add
    alias_action :edit, :update, to: :modify
    alias_action :index, :show, to: :view

    if user.has_role? :administrator
      can :manage, Achievement
      can :manage, Objective

      can :add, Category
      can :add, Mode
      can :add, Type
      can :modify, Continent
      can :modify, Region
      can :modify, Country

      can :modify, Category
      can :modify, Continent
      can :modify, Region
      can :modify, Country

      can :destroy, Category
      can :destroy, Country
      can :destroy, Continent
      can :destroy, Region
    end

    can :manage, Achievement, user_id: user.id
    
    # User can manage ListContent for received shared lists
    can :manage, ListContent, list_id: user.received_lists.pluck(:id)
    can :manage, ListContent, list_id: user.lists.pluck(:id)
    
    # Users can also manage their own lists
    can :manage, List, user_id: user.id
    

    can :manage, FriendRequest, user_id: user.id
    can :manage, FriendRequest, to_id: user.id
    can :manage, CoopRequest, user_id: user.id
    can :manage, CoopRequest, target_id: user.id
    can :manage, Tracked, user_id: user.id
    can :manage, SharedAchievement, user_id: user.id
    can :destroy, SharedAchievement, to_id: user.id
    can :manage, SharedList, user_id: user.id
    can :manage, AchievementDependency, achievement: { user_id: user.id }
    can :add, Objective, achievements: { user_id: user.id }
    can :destroy, Objective, achievements: { user_id: user.id }

    can :view, Achievement, is_global: true
    can :view, Category
    can :view, Continent
    can :view, Country
    can :view, List, is_public: true
    can :view, ListContent, list: { is_public: true }
    can :view, Objective, is_public: true
    can :view, Region
    can :view, Title
    can :view, Unlocked
    can :view, User
    can :destroy, ListContent, list_id: user.lists.pluck(:id)


    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
