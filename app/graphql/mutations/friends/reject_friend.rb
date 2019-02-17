class Mutations::Friends::RejectFriend < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Identifies and rejects a friend request by id. The friend request
  will be deleted, so make sure to query for the friends connection
  and update it on the client.
  This can also be used to cancel a friend request, by rejecting
  the users own (sent) friend requests.
  DESC
  argument :id, String, required: true,
  description: "Friend request ID to Reject"
  

  field :friend_request, Types::Social::FriendRequestType, null: true
  field :user, Types::Social::UserType, null: false
  field :friend, Types::Social::UserType, null: false
  field :errors, [String], null: false

  def resolve(id: nil)
    friend_request = ::FriendRequest.find(id)

    authorize! :delete, friend_request
    friend_request.destroy

    {
      friend_request: friend_request,
      user: context[:current_user],
      friend: friend,
      errors: [],
    }

  rescue CanCan::AccessDenied => exception
    {
      friend_request: nil,
      user: context[:current_user],
      friend: nil,
      errors: [exception.message]
    }
  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      friend_request: nil,
      user: context[:current_user],
      friend: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      friend_request: nil,
      user: context[:current_user],
      friend: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      friend_request: nil,
      user: context[:current_user],
      friend: nil,
      errors: [ error.message ]
    }
  end
end
