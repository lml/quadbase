module Api
  module V1
    class ApiController < ApplicationController      
      skip_before_filter :authenticate_user!
      
      respond_to :json

      rescue_from Exception, :with => :rescue_from_exception
      
    private

      def current_user
        @current_user ||= doorkeeper_token ? 
                          User.find(doorkeeper_token.resource_owner_id) : 
                          AnonymousUser.instance
      end

      def rescue_from_exception(exception)
        # See https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L453 for error names/symbols

        error = :internal_server_error
        send_email = true
    
        case exception
        when SecurityTransgression
          error = :forbidden
          send_email = false
        when ActiveRecord::RecordNotFound, 
             ActionController::RoutingError,
             ActionController::UnknownController,
             AbstractController::ActionNotFound
          error = :not_found
          send_email = false
        end

        DeveloperErrorNotifier.exception_email(exception, request, present_user) if send_email
        head error
      end

    end
  end
end