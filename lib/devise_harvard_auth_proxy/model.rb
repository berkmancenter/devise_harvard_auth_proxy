require 'devise_ldap_authenticatable/strategy'

module Devise
  module Models
    # Authzproxy Module, responsible for validating the user credentials via LDAP.

    module AuthzproxyAuthenticatable

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def authenticate_with_authzproxy(azp_token,external_ip)
          Rails.logger.warn('azp: ' + azp_token)
          Rails.logger.flush
          decrypted_azp_token = decrypt_authzproxy_token(azp_token)
          user_info = parse_and_validate_authzproxy_token(decrypted_azp_token,external_ip)
          Rails.logger.warn('User info: ' + user_info.inspect)
          Rails.logger.flush
          return user_info
        end

        private

        def decrypt_authzproxy_token(encrypted_message)
          begin
            Open3.popen3(Devise.gpg_path, '--decrypt',"--homedir=#{Devise.gpg_home}","--passphrase=#{Devise.gpg_passphrase}","--no-tty", '2>', '/dev/null') do |stdin, stdout, error|
              stdin.write(encrypted_message)
              stdin.close
              stdout.read
            end
          rescue Exception => e
            return nil
          end
        end

        def parse_and_validate_authzproxy_token(decrypted_message, external_ip)
          encoded_data, encoded_signature = decrypted_message.split('&')
          data      = CGI.unescape(encoded_data)
          signature = CGI.unescape(encoded_signature)
          authentication_data, encoded_attribute_data = data.split('&')
          return nil unless valid_authentication_data(authentication_data, external_ip)
          attribute_data = Hash[CGI.unescape(encoded_attribute_data).split('|').collect { |el| el.split('=') }]
          return attribute_data
        end

        def valid_authentication_data(authentication_data, external_ip)
          user_id, time_stamp, user_ip, app_id, id_type = authentication_data.split('|')

          # TODO - check against ip address.
          return false unless user_ip == external_ip

          # check for expired time_stamp
          return false if Time.parse(time_stamp).localtime + 120 < Time.now

          # check for invalid application ID
          return false if app_id != Devise.authen_application
          return true
        end

      end
    end
  end
end
