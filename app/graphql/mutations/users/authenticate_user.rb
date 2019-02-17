class Mutations::Users::AuthenticateUser < Mutations::BaseMutation
  argument :provider, Types::Social::OauthProviderType, required: true
  argument :token, String, required: true
  

  field :user, Types::Social::CurrentUserType, null: true
  field :errors, [String], null: false

  def resolve(provider: nil, token: nil)
    case provider.to_sym
    when :google
      identity = ::Identity.from_google(token: token)
    when :demo
      raise ActiveRecord::RecordNotFound.new unless ::Identity.where(provider: :DEMO).pluck(:token).to_a.include?(token)
      identity = ::Identity.find_by(token: token)
    end

    # FIXME: This is temporary since we just added the avatar_url field,
    # we need to ensure all users have an avatar_url before they're signed in
    if identity.user && identity.user.avatar && identity.user.avatar_url.nil?
      identity.user.update_attributes(avatar_url: Digest::SHA1.hexdigest(identity.user.avatar))
    end

    {
      user: identity.user,
      errors: []
    }

  rescue ActiveRecord::RecordInvalid => invalid
    # Failed save, return the errors to the client
    {
      user: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotSaved => error
    # Failed save, return the errors to the client
    {
      user: nil,
      errors: invalid.record.errors.full_messages
    }
  rescue ActiveRecord::RecordNotFound => error
    {
      user: nil,
      errors: [ error.message ]
    }
  end

  private
  def auth_token
    if entity.respond_to? :to_token_payload
      AuthToken.new payload: entity.to_token_payload
    else
      AuthToken.new payload: { sub: entity.id }
    end
  end
end
