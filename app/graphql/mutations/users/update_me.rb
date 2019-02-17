class Mutations::Users::UpdateMe < Mutations::BaseMutation
  argument :name, String, required: false
  argument :avatar, String, required: false
  argument :email, String, required: false
  argument :allow_coop, Boolean, required: false
  

  field :user, Types::Social::CurrentUserType, null: true
  field :errors, [String], null: false

  def resolve(name: nil, avatar: nil, email: nil, allow_coop: nil)
   
    user = context[:current_user]

    user.assign_attributes(name: name) if name
    if avatar
      user.assign_attributes(avatar: avatar, avatar_url: Digest::SHA1.hexdigest(avatar))
      
    end
    user.assign_attributes(email: email) if email
    user.assign_attributes(allow_coop: allow_coop) unless allow_coop.nil?
    
    # Force the cache to ensure we re-cache the object after updating
    context[:force_cache] = true;

    user.save!
    {
      user: user,
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
