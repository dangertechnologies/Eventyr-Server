# == Schema Information
#
# Table name: identities
#
#  id            :bigint(8)        not null, primary key
#  user_id       :bigint(8)
#  provider      :string
#  uid           :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  token         :text
#  token_expires :datetime
#
# Indexes
#
#  index_identities_on_user_id  (user_id)
#
require "open-uri"

class Identity < ApplicationRecord
  belongs_to :user
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider


  def self.from_google(token: nil)
    begin
      payload = GoogleIDToken::Validator.new.check(
        token,
        Rails.application.secrets.google_client_audience
      )
    rescue GoogleIDToken::AudienceMismatchError
      payload = GoogleIDToken::Validator.new.check(
        token,
        Rails.application.secrets.google_client_audience_web
      )
    end
    
    identity = find_for_app_auth(
      uid: payload["sub"],
      provider: :GOOGLE
    )

    

    if identity.user.nil?
      avatar = Base64.encode64(open(payload["picture"]).read)
      u = User.create!(
        name: payload["given_name"],
        role: Role.find_by(name: "Achiever"),
        email: payload["email"],
        personal_points: 0,
        points: 0,
        scan_radius: 50,
        auto_share: false,
        password: SecureRandom.base58(24),
        avatar: avatar,
        avatar_url: Digest::SHA1.hexdigest(avatar)
      )

      identity.update_attributes!(user: u)
    end

    identity
  end

  def self.find_for_app_auth(uid: nil, provider: nil)
    if identity = Identity.find_by(provider: provider, uid: uid)
      identity
    else
      create(
        uid: uid,
        provider: provider,
      )
    end
  end


  # Used with OmniAuth and no longer needed.
  # @deprecated
  def self.find_for_oauth(auth)

    # Get credentials
    unless auth.credentials.token.nil? or auth.credentials.token.blank?
      token = auth.credentials.token
      expires = auth.credentials.expires_at || nil
      puts auth.to_yaml
      puts token
      puts expires
    end

  	# Try to find the identity with provided credentials
  	identity = find_by(provider: auth.provider, uid: auth.uid)

    identity.update(token: token, token_expires: expires) unless identity.nil?

  	# If none can be found, create an identity
  	identity = create(uid: auth.uid, provider: auth.provider, token: token, token_expires: expires) if identity.nil?

  	# Return identity
  	identity
  end
end
