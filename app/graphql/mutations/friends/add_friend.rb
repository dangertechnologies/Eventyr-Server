class Mutations::Friends::AddFriend < Mutations::BaseMutation
  requires_authentication
  description <<-DESC
  Identifies and adds a friend request by id. The friend request
  will be deleted, and the sender will be added to the user's friends.
  Make sure to query for the friends connection, or the friend field,
  and update the connection on the client.
  DESC
  argument :user_ids, [String], required: true,
                             description: 'User to send a friend request to'
  argument :message, String, required: false

  field :friend_requests, [Types::Social::FriendRequestType], null: true
  field :user, Types::Social::UserType, null: false
  field :errors, [String], null: false

  def resolve(user_ids: nil, message: '')
    friend_requests = user_ids.map do |user_id|
      friend = User.find(user_id)
      if context[:current_user].friends.include?(friend)
        errors << "You're already friends with #{friend.name}"
        next
      end
      friend_request = ::FriendRequest.find_or_initialize_by(
        user_id: context[:current_user].id,
        to_id: user_id.to_i,
      )

      authorize! :create, friend_request

      friend_request.assign_attributes(message: message) if friend_request.new_record?

      friend_request.save!
      friend_request
    end

    
    {
      friend_requests: friend_requests,
      user: context[:current_user],
      errors: []
    }
    
  rescue CanCan::AccessDenied => exception
    {
      friend_requests: nil,
      user: context[:current_user],
      errors: [exception.message]
    }
  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      friend_requests: nil,
      user: context[:current_user],
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      friend_requests: nil,
      user: context[:current_user],
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      friend_requests: nil,
      user: context[:current_user],
      errors: [error.message]
    }
  end
end
