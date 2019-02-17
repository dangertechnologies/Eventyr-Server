class Mutations::Share::ShareList < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Shares an Achievement with a user. If the Achievement is a private
  Achievement, the receiving user will be granted access to it,
  allowing it to appear in their feed, and letting them complete it.
  DESC

  argument :list_id, String, required: false,
  description: "Achievement to share"
  argument :user_ids, [String], required: true,
  description: "User to send request to"

  field :share_requests, [Types::Social::SharedListType], null: true
  field :errors, [String], null: false

  def resolve(list_id: nil, user_ids: nil, message: nil)
    share_requests = user_ids.map do |user_id|
      ::SharedList.find_or_create_by(
        list_id: list_id.to_i,
        user_id: context[:current_user].id,
        target_id: user_id.to_i,
      )
    end

    {
      share_requests: share_requests,
      errors: [],
    }

  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      share_requests: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      share_requests: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      share_requests: nil,
      errors: [ error.message ]
    }
  end
end
