class Mutations::Lists::RemoveFromList < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Removes achievements to an existing list. User can only remove
  achievements from a list if a) the user owns it or b) the
  list has been shared with the user and the user has been
  granted access rights.
  DESC
  argument :list_id, String, required: true,
  description: "ID of the list to remove achievements from"
  argument :achievement_ids, [String], required: true,
  description: "Achievements to remove"
  

  field :list, Types::Achievements::ListType, null: true
  field :removed_ids, [String], null: true
  field :errors, [String], null: false

  def resolve(list_id: nil, achievement_ids: [])
    list = ::List.find(list_id)
    content = list.list_content.where(achievement_id: achievement_ids.map(&:to_i))
    content.each do |list_item|
      authorize! :destroy, list_item
    end

    {
      list:  list,
      removed_ids: content.destroy_all.map(&:achievement_id),
      errors: [],
    }

  rescue CanCan::AccessDenied => exception
    {
      list: nil,
      removed_ids: null,
      errors: [exception.message]
    }

  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      list: nil,
      removed_ids: null,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      list: nil,
      removed_ids: null,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      list: nil,
      removed_ids: null,
      errors: [ error.message ]
    }
  end
end
