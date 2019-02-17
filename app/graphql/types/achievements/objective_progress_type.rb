module Types
  module Achievements
    class ObjectiveProgressType < Types::BaseObject
      description <<-DESC
ObjectiveProgress keeps track of a) if a user has completed
an objective and b) how many times the user has completed the
objective.
Because objectives may require the user to reach a certain number
of completions, there needs to be a user-oriented way to track
how many times an objective has been "completed" before its
actually marked as **completed**.
When the Objective.requiredCount (default: 1) is reached
for a user, the objective is considered to be completed.
DESC
      field :id, ID, null: false
      field :user, Social::UserType, null: false
      field :objective, Achievements::ObjectiveType, null: false,
      description: "The objective this progress concerns"
      field :completed, Boolean, null: false,
      description: "Whether or not the objective has been completed enough times"
      field :times_completed, Boolean, null: false,
      description: "How many times the user has completed the objective"
      field :created_at, Integer, null: false
      field :updated_at, Integer, null: false

      def times_completed
        object.current_count
      end
    end
  end
end