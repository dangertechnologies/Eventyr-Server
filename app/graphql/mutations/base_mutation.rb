class Mutations::BaseMutation < GraphQL::Schema::RelayClassicMutation
  include CanCan::ControllerAdditions # Permissions

  # Wraps fields on a query with authentication checks,
  # by checking if current_user is nil. current_user
  # will always be set from the JWT token in GraphQLController,
  # so if no current_user exists, the authentication failed.
  # We avoid raising the error there, to allow us to have
  # control of each individual field instead.
  # 
  # Because queries require us to define fields as methods,
  # we can wrap those methods with a check for current_user.
  # If no method names are provided, fall back to "resolve",
  # to allow us to just use `requires_authentication` on
  # mutations.
  #
  # @param [Array<Symbol>] method_names
  def self.requires_authentication(*method_names)
    method_names = [:resolve] if method_names.nil? || method_names.empty?
    method_names.each do |m|
      proxy = Module.new do
        define_method(m) do |*args|
          authenticate!
          super *args
        end
      end
      self.prepend proxy
    end
  end


  def authenticate!
    raise ::ActionController::InvalidAuthenticityToken.new("Unauthorized") if context[:current_user].nil?
  end
  
  def current_user
    context[:current_user]
  end
end