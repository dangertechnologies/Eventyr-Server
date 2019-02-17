module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include Knock::Authenticable
    include CanCan::ControllerAdditions # Permissions

    identified_by :authenticated_user

    def connect
      authenticate_user
      self.authenticated_user = current_user
    end  

    def disconnect
      # Any cleanup work needed when the cable connection is cut.
    end

    protected
    def token
      header_array = request.headers[:HTTP_SEC_WEBSOCKET_PROTOCOL].split(',')
      token = header_array[header_array.length-1]
      return nil if token.blank?
      token.strip
    end

    def unauthorized_entity(args)
    end
  end
end
