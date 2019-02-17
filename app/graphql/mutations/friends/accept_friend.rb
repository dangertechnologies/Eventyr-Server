  class Mutations::Friends::AcceptFriend < Mutations::BaseMutation
    requires_authentication
    description <<-DESC
    Identifies and accepts a friend request by id. The friend request
    will be deleted, and the sender will be added to the user's friends.
    Make sure to query for the friends connection, or the friend field,
    and update the connection on the client.
    DESC
    argument :id, String, required: true,
    description: "Friend request ID to accept"
    

    field :friend_request, Types::Social::FriendRequestType, null: true
    field :user, Types::Social::UserType, null: false
    field :friend, Types::Social::UserType, null: false
    field :errors, [String], null: false

    def resolve(id: nil)
      friend_request = ::FriendRequest.find(id)
      friend = friend_request.user

      authorize! :update, friend_request
      context[:current_user].friends << friend

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
