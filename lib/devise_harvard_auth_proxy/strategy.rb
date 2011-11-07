require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Strategy for signing in a user based on the harvard authzproxy token.
    # Redirects to sign_in page if it's not authenticated
    class HarvardAuthProxyAuthenticatable < Base
      def valid?
        Rails.logger.warn( 'In valid?: ' + mapping.to.respond_to?(:authenticate_with_harvard_auth_proxy).to_s )
        mapping.to.respond_to?(:authenticate_with_harvard_auth_proxy)
      end

      # Authenticate a user based on login and password params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      def authenticate!
        unless params[:_azp_token].blank?
          Rails.logger.warn('In authenticate!')
          if resource = mapping.to.authenticate_with_harvard_auth_proxy(params[:_azp_token], request.remote_ip)
            Rails.logger.warn('In authenticate!: success!')
            success!(resource)
          else
            Rails.logger.warn('In authenticate!: fail!')
            redirect!(Devise.pin_url + Devise.authen_application)
          end
        else
          Rails.logger.warn('In authenticate!: no token!')
          redirect!(Devise.pin_url + Devise.authen_application)
        end
      end
    end
  end
end

Warden::Strategies.add(:harvard_auth_proxy_authenticatable, Devise::Strategies::HarvardAuthProxyAuthenticatable)
