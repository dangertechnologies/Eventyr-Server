class Mutations::Achievements::Upvote < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Upvote an Achievement. If the user has already downvoted the
  achievement, his/her vote will be changed.
  DESC
  argument :achievement_id, String, required: true,
  description: "Achievement to upvote"
  

  field :achievement, Types::Achievements::AchievementType, null: true
  field :errors, [String], null: false

  def resolve(id: nil)
    achievement = ::Achievement.find(id)
    context[:current_user].upvote(achievement)

    {
      achievement: achievement,
      errors: [],
    }

  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      achievement: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      achievement: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      achievement: nil,
      errors: [ error.message ]
    }
  end
end
