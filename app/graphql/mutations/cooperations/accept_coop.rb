class Mutations::Cooperations::AcceptCoop < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Accepts a cooperation request by setting pending: false. Rejected
  coop requests are deleted, so if a coop request has pending: false,
  it's an active cooperation link between two users
  DESC

  argument :id, String, required: true

  field :coop_request, Types::Social::CoopRequestType, null: true
  field :errors, [String], null: false

  def resolve(id: nil)
    coop_request = ::CoopRequest.find(id)

    authorize! :update, coop_request

    coop_request.update_attributes(pending: false)

    # Successful creation, return the created object with no errors
    {
      coop_request: coop_request,
      errors: [],
    }

  rescue CanCan::AccessDenied => exception
    {
      achievement: nil,
      objectives: [],
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
