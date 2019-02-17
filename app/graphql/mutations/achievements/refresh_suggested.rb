  class Mutations::Achievements::RefreshSuggested < Mutations::BaseMutation
    requires_authentication
    description <<-DESC
      Automatically refreshes suggested Achievements by removing currently suggested Achievements (not Pinned/Favorited)
      that are too far away from the current location, and repopulates the users suggested Achievements with all Achievement within range.
      The User could choose to do this manually by searching for nearby achievements, or view suggested Achievements, after 
      this mutation is called automatically.
    DESC
    argument :coordinates, [Float], required: false
    

    field :achievements, Types::Achievements::AchievementType.connection_type, null: true
    field :errors, [String], null: false

    def resolve(coordinates: [])
      
      latitude, longitude = coordinates

      context[:current_user].refresh_suggested_achievements(latitude: latitude, longitude: longitude)

      {
        achievements: Achievement.includes(:objectives, :category, :user).where(id: context[:current_user].tracked.pluck(:achievement_id)),
        errors: [],
      }

    rescue ActiveRecord::RecordInvalid => invalid
      # Failed save, return the errors to the client
      {
        achievements: nil,
        errors: invalid.record.errors.full_messages
      }
    rescue ActiveRecord::RecordNotSaved => error
      # Failed save, return the errors to the client
      {
        achievements: nil,
        errors: invalid.record.errors.full_messages
      }
    rescue ActiveRecord::RecordNotFound => error
      {
        achievements: nil,
        errors: [ error.message ]
      }
    end
  end
