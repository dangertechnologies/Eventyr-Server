  class Mutations::Achievements::CompleteObjective < Mutations::BaseMutation
    requires_authentication

    description <<-DESC
    Complete, or partially complete, an objective. 
    Objectives that must be completed multiple times will have their counter
    incremented, and will become completed once the required completion count
    is met.
    Any achievements that become unlocked by completing this objective will
    also be returned.
    DESC
    argument :id, String, required: true
    argument :coordinates, [Float], required: false
    argument :timestamp, Integer, required: true
    

    field :objective_progress, Types::Achievements::ObjectiveProgressType, null: true
    field :unlocked_achievements, [Types::Achievements::UnlockedType], null: true
    field :errors, [String], null: false

    def resolve(id: nil, coordinates: nil, timestamp: nil)
      progress = ::ObjectiveProgress.includes(:objective, :user).find_or_initialize_by(user: context[:current_user], objective_id: id)

      latitude, longitude = coordinates


      progress = progress.objective.complete(user: context[:current_user], x: latitude, y: longitude)
      unlocked = Achievement.unlockable(context[:current_user]).where(objectives: { id: progress.objective.id })

      # Unlock eligible achievements
      unlocked = unlocked.map do |achievement|
        achievement.unlock(context[:current_user], time: timestamp ? Time.at(timestamp) : nil)
      end

      {
        objective_progress:  progress,
        unlocked_achievements: unlocked.select { |u| u.is_a?(Unlocked) },
        errors: []
      }
     
    rescue Objective::TooFarAwayException => error
      {
        objective_progress: nil,
        unlocked_achievements: [],
        errors: [error.message]
      }

    rescue ActiveRecord::RecordInvalid => invalid
      # Failed save, return the errors to the client
      {
        objective_progress: nil,
        errors: invalid.record.errors.full_messages
      }
    rescue ActiveRecord::RecordNotSaved => error
      # Failed save, return the errors to the client
      {
        objective_progress: nil,
        errors: invalid.record.errors.full_messages
      }
    rescue ActiveRecord::RecordNotFound => error
      {
        objective_progress: nil,
        errors: [ error.message ]
      }
    end
  end
