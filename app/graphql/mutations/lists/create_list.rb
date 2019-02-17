class Mutations::Lists::CreateList < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
    Creates a new user-owned list, optionally
    populated by Achievements (but can be empty initially as well)
  DESC
  argument :title, String, required: true,
  description: 'Name of the list'

  argument :is_public, Boolean, required: false, default_value: false,
  description: 'Whether or not this list should be visible for other users'

  argument :achievement_ids, [String], required: false,
  description: 'List of Achievement IDs to add to the list'

  field :list, Types::Achievements::ListType, null: true
  field :errors, [String], null: false

  def resolve(title: nil, achievement_ids: [], is_public: false)
    list = context[:current_user].lists.create(
      title: title,
      is_public: is_public
    )

    list.save!
    list.list_content.create(achievement_ids.map { |i| { achievement_id: i } }) unless achievement_ids.empty?

    # Successful creation, return the created object with no errors
    {
      list:  list,
      errors: []
    }
  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      list: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      list: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      list: nil,
      errors: [error.message]
    }
  end
end
