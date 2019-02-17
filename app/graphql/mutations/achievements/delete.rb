class Mutations::Achievements::Delete < Mutations::BaseMutation
  requires_authentication
  argument :id, String, required: true
  

  field :achievement, Types::Achievements::AchievementType, null: true
  field :objectives, [Types::Achievements::ObjectiveType], null: true
  field :errors, [String], null: false

  def resolve(id: nil)
    
    # Create the Achievement
    achievement = Achievement.includes(:objectives).find(id)

    authorize! :delete, achievement

    # Intentionally DONT subtract rewarded points for the
    # achievement. Users who completed an achievement should
    # not be punished when its removed - they've still done
    # the deed.

    # Now delete all related objectives if they have 
    # no other achievements
    objectives = []
    achievement.objectives.each do |o|
      if o.achievements.count == 1 && can?(:delete, o)
        objectives << []
        o.destroy 
      end
    end

    # Remove all Tracked
    Tracked.where(achievement: achievement).delete_all

    achievement.destroy


    {
      achievement: achievement,
      objectives: objectives,
      errors: [],
    }

  rescue CanCan::AccessDenied => exception
    {
      achievement: nil,
      objectives: [],
      errors: [exception.message]
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      achievement: nil,
      objectives: [],
      errors: [error.message]
    }
  end
end