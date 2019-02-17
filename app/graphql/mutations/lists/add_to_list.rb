class Mutations::Lists::AddToList < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Adds achievements to an existing list. User can only add
  achievements to a list if a) the user owns it or b) the
  list has been shared with the user and the user has been
  granted access rights.
  DESC
  argument :list_ids, [String], required: true,
  description: "ID of the list to add achievements to"
  argument :achievement_ids, [String], required: true
  

  field :lists, [Types::Achievements::ListType], null: true
  field :errors, [String], null: false

  def resolve(list_ids: nil, achievement_ids: [])

    list_ids.each do |id|
      authorize! :create, ListContent.new(list_id: id.to_i)
    end
    

    list_ids.each do |id|
      ::ListContent.create(achievement_ids.map { |i| { list_id: id.to_i, achievement_id: i.to_i } } )
    end

    # Remove from users lists that were *not* selected (e.g deselected)
    ::ListContent.includes(:list).where(
      achievement_id: achievement_ids.map(&:to_i),
      list_id: ::List.where(user: context[:current_user]).pluck(:id).reject{|i| list_ids.map(&:to_i).include?(i) }
    ).destroy_all

    {
      lists:  ::List.includes(:achievements).where(id: list_ids.map(&:to_i)),
      errors: [],
    }

  rescue CanCan::AccessDenied => exception
    {
      lists: nil,
      errors: [exception.message]
    }

  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      lists: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      lists: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      lists: nil,
      errors: [ error.message ]
    }
  end
end
