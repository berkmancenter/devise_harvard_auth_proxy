module Devise
  module Models
    # Authzproxy Module, responsible for validating the authzproxy token and getting user data..

    module HarvardAuthProxyAuthenticatable

      def self.included(base)
        Rails.logger.warn('Init!')
        base.extend ClassMethods
      end

      module ClassMethods
        def authenticate_with_harvard_auth_proxy(azp_token,external_ip)
          Rails.logger.warn('azp: ' + azp_token)
          decrypted_azp_token = decrypt_authzproxy_token(azp_token)
          Rails.logger.warn("decrypted_azp_token #{decrypted_azp_token}")
          user_info = parse_and_validate_authzproxy_token(decrypted_azp_token,external_ip)
          Rails.logger.warn('User info: ' + user_info.inspect)
          return nil if user_info.nil?
          # Find the user account.
          resource = find(:first, :conditions => { Devise.identifier => user_info[Devise.identifier]})
          if resource.nil?
            resource = new(user_info)
            resource.save!
          end

          return resource
        end

        private

        def decrypt_authzproxy_token(encrypted_message)
          begin
            command = [
              Devise.gpg_path, 
              '--decrypt',
              ((Devise.gpg_home.nil?) ? '' : "--homedir=#{Devise.gpg_home}"),
              ((Devise.gpg_passphrase.nil?) ? '' : "--passphrase=#{Devise.gpg_passphrase}"),"--no-tty", '2>', '/dev/null'
            ]
            Rails.logger.warn("Command: #{command.join(" ")}")
            Open3.popen3(command.join(' ')) do |stdin, stdout, error|
              stdin.write(encrypted_message)
              stdin.close
              stdout.read
            end
          rescue Exception => e
            Rails.logger.warn("Decryption error: #{e.inspect}")
            return nil
          end
        end

        def parse_and_validate_authzproxy_token(decrypted_message, external_ip)
          encoded_data, encoded_signature = decrypted_message.split('&')
          data      = CGI.unescape(encoded_data)
          signature = CGI.unescape(encoded_signature)
          authentication_data, encoded_attribute_data = data.split('&')
          Rails.logger.warn("data: #{data} || signature: #{signature} || authentication_data: #{authentication_data} || encoded_attribute_data: #{encoded_attribute_data}")
          attribute_data = Hash[CGI.unescape(encoded_attribute_data).split('|').collect { |el| el.split('=') }]
          Rails.logger.warn("Attribute Data: #{attribute_data.inspect}")
          return nil unless valid_authentication_data(authentication_data, external_ip)
          return attribute_data
        end

        def valid_authentication_data(authentication_data, external_ip)
          user_id, time_stamp, user_ip, app_id, id_type = authentication_data.split('|')

          Rails.logger.warn("user_id: #{user_id} || time_stamp: #{time_stamp} || external_ip: #{external_ip} || user_ip: #{user_ip} || app_id: #{app_id} || id_type: #{id_type}")

          # check against ip address.
#          return false unless user_ip == external_ip

          # check for expired time_stamp
#          return false if Time.parse(time_stamp).localtime + 120 < Time.now

          # check for invalid application ID
          return false if app_id != Devise.authen_application
          return true
        end

      end
    end
  end
end
