class Mutations::Share::RejectList < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Identifies and rejects a list share request by id. The share request
  will be deleted, so make sure to query for the connection
  and update it on the client.
  DESC
  argument :id, String, required: true,
  description: "SharedList request ID to Reject"
  

  field :share_request, Types::Social::SharedListType, null: true
  field :errors, [String], null: false

  def resolve(id: nil)
    share_request = ::SharedList.find(id)

    authorize! :delete, share_request
    share_request.destroy

    {
      share_request: share_request,
      errors: [],
    }

  rescue CanCan::AccessDenied => exception
    {
      share_request: nil,
      errors: [exception.message]
    }
  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      share_request: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      share_request: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      share_request: nil,
      errors: [ error.message ]
    }
  end
end
