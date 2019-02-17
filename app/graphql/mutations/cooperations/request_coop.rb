class Mutations::Cooperations::RequestCoop < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Requests cooperation mode with another user, either for an entire List,
  or for a single achievement
  DESC

  argument :list_id, String, required: false,
  description: "List to request coop for" 
  argument :achievement_id, String, required: false,
  description: "Achievement to request coop for"
  argument :user_ids, [String], required: true,
  description: "User to send request to"
  argument :message, String, required: true,
  description: "Message to show the receiving user"

  field :coop_requests, [Types::Social::CoopRequestType], null: true
  field :errors, [String], null: false

  def resolve(list_id: nil, achievement_id: nil, user_ids: nil, message: nil)
    coop_requests = user_ids.map do |user_id|
        coop_request = ::CoopRequest.find_or_create_by!(
          achievement_id: achievement_id.to_i,
          user_id: context[:current_user].id,
          target_id: user_id.to_i,
          pending: true,
          message: message
        )

        coop_request
      end

    {
      coop_requests:  coop_requests,
      errors: [],
    }

  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      coop_requests: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      coop_requests: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      coop_requests: nil,
      errors: [ error.message ]
    }
  end
end
