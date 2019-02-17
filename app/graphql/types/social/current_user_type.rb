module Types
  module Social
    class CurrentUserType < UserType
      description <<-DESC
      Same as UserType, but always contains a new authenticationToken
      the user may use to authenticate.

      TODO: Cache this token, instead of generating a new one on every request.
      DESC
      field :authentication_token, String, null: false

      def authentication_token
        Knock::AuthToken.new(payload: { sub: object.id }).token
      end
    end
  end
end
