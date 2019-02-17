class Types::Subscriptions::SubscriptionType < Types::BaseObject
  field :notification_received, Types::Social::NotificationType, null: true,
  subscription_scope: :current_user_id,
  description: "User received a notification"

  def notification_received(*args)
    # Called on initial request
    # Set up authentication here
  end
end
