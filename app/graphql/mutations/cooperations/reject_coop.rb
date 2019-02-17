class Mutations::Cooperations::RejectCoop < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Declines a cooperation request by removing it. Rejected
  coop requests are deleted, while accepted cooperation requests
  set pending: false.
  DESC
  argument :id, String, required: true

  field :coop_request, Types::Social::CoopRequestType, null: true
  field :errors, [String], null: false

  def resolve(id: nil)
    coop_request = ::CoopRequest.find(id)

    authorize! :delete, coop_request

    {
      coop_request:  coop_request.destroy,
      errors: [],
    }

  rescue CanCan::AccessDenied => exception
    {
      coop_request: nil,
      errors: [exception.message]
    }
  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      coop_request: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      coop_request: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      coop_request: nil,
      errors: [ error.message ]
    }
  end
end
