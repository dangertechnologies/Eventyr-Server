class Mutations::Friends::RemoveFriend < Mutations::BaseMutation
  requires_authentication
  description 'Removes friendship with a user specified by user ID'
  argument :user_id, String, required: true

  field :user, Types::Social::UserType, null: true, description: 'Current user'
  field :errors, [String], null: false

  def resolve(user_id: nil)
    context[:current_user].friends.find(id: user_id).delete

    {
      user:  context[:current_user],
      errors: [],
    }

  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      user: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      user: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      user: nil,
      errors: [ error.message ]
    }
  end
end
