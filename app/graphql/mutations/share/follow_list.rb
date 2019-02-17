class Mutations::Share::FollowList < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Follow another users list, making it show up when querying for
  current users lists, but with another author.
  DESC

  argument :list_id, String, required: false,
  description: "List to follow"
  
  field :list, Types::Achievements::ListType, null: true
  field :errors, [String], null: false

  def resolve(list_id: nil)
    followed_list = FollowedList.find_or_create_by!(list_id: list_id, user: context[:current_user])

    {
      list: followed_list.list,
      errors: [],
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
