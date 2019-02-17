class Mutations::Lists::UpdateList < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Update name / public status of a list
  DESC
  argument :id, String, required: true,
  description: "ID of the list to update"
  argument :title, String, required: true,
  description: 'Name of the list'

  argument :is_public, Boolean, required: false, default_value: false,
  description: 'Whether or not this list should be visible for other users'
  

  field :list, Types::Achievements::ListType, null: true
  field :errors, [String], null: false

  def resolve(id: nil, title: "", is_public: false)
    list = ::List.find(id)

    authorize! :update, list

    list.update_attributes(title: title, is_public: is_public)

    {
      list:  list,
      errors: [],
    }

  rescue CanCan::AccessDenied => exception
    {
      list: nil,
      errors: [exception.message]
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
      errors: [ error.message ]
    }
  end
end
