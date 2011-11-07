require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Strategy for signing in a user based on the harvard authzproxy token.
    # Redirects to sign_in page if it's not authenticated
    class HarvardAuthProxyAuthenticatable < Authenticatable
      def valid?
        valid_controller? && valid_params? && mapping.to.respond_to?(:authenticate_with_harvard_auth_proxy)
      end

      # Authenticate a user based on login and password params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      def authenticate!
        if resource = mapping.to.authenticate_with_harvard_auth_proxy(params[scope])
          success!(resource)
        else
          fail(:invalid)
        end
     end

      protected

        def valid_controller?
          params[:controller] == mapping.controllers[:sessions]
        end

        def valid_params?
          params[scope] && params[scope][:password].present?
        end
    end
  end
end

Warden::Strategies.add(:harvard_auth_proxy_authenticatable, Devise::Strategies::HarvardAuthProxyAuthenticatable)
