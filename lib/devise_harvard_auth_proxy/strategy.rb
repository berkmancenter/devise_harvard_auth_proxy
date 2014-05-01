require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    # Strategy for signing in a user based on the harvard authzproxy token.
    # Redirects to sign_in page if it's not authenticated
    class HarvardAuthProxyAuthenticatable < Base
      def valid?
        mapping.to.respond_to?(:authenticate_with_harvard_auth_proxy) &&
          (!params.include?(:user) || !params[:user].include?(:password))
      end

      # Authenticate a user based on login and password params, returning to warden
      # success and the authenticated user if everything is okay. Otherwise redirect
      # to sign in page.
      def authenticate!
        unless params[:_azp_token].blank?
          Rails.logger.warn('In authenticate!') if Devise.debug
          if resource = mapping.to.authenticate_with_harvard_auth_proxy(params[:_azp_token], request.remote_ip)
            Rails.logger.warn('In authenticate!: success!') if Devise.debug
            success!(resource)
          else
            Rails.logger.warn('In authenticate!: fail!') if Devise.debug
            redirect!("#{Devise.pin_url}#{Devise.authen_application}&_redirect_to=" + CGI.escape(params[:_redirect_to]))
          end
        else
          Rails.logger.warn('In authenticate!: no token!') if Devise.debug
          redirect!("#{Devise.pin_url}#{Devise.authen_application}&_redirect_to=" + CGI.escape(request.url))
        end
      end
    end
  end
end

Warden::Strategies.add(:harvard_auth_proxy_authenticatable, Devise::Strategies::HarvardAuthProxyAuthenticatable)
