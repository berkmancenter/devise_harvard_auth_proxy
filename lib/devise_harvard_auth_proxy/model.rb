module Devise
  module Models
    # Authzproxy Module, responsible for validating the authzproxy token and getting user data..

    module HarvardAuthProxyAuthenticatable

      def self.included(base)
        Rails.logger.warn('Init!') if Devise.debug
        base.extend ClassMethods
      end

      module ClassMethods
        def authenticate_with_harvard_auth_proxy(azp_token,external_ip)
          Rails.logger.warn('azp: ' + azp_token) if Devise.debug
          decrypted_azp_token = decrypt_authzproxy_token(azp_token)
          Rails.logger.warn("decrypted_azp_token #{decrypted_azp_token}") if Devise.debug
          token_info = parse_and_validate_authzproxy_token(decrypted_azp_token,external_ip)
          Rails.logger.warn('Parsed token information: ' + token_info.inspect) if Devise.debug
          return nil if token_info.nil?
          # Find the user account.
          resource = find(:first, :conditions => { Devise.identifier => token_info[:user_info][Devise.identifier]})
          if resource.nil?
            resource = new
            Devise.creation_attributes.call(resource,token_info[:user_info], token_info[:authentication_info])
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
            Rails.logger.warn("Command: #{command.join(" ")}") if Devise.debug
            Open3.popen3(command.join(' ')) do |stdin, stdout, error|
              stdin.write(encrypted_message)
              stdin.close
              stdout.read
            end
          rescue Exception => e
            Rails.logger.warn("Decryption error: #{e.inspect}") if Devise.debug
            return nil
          end
        end

        def parse_and_validate_authzproxy_token(decrypted_message, external_ip)
          encoded_data, encoded_signature = decrypted_message.split('&')
          data      = CGI.unescape(encoded_data)
          signature = CGI.unescape(encoded_signature)
          authentication_data, encoded_attribute_data = data.split('&')
          Rails.logger.warn("data: #{data} || signature: #{signature} || authentication_data: #{authentication_data} || encoded_attribute_data: #{encoded_attribute_data}")  if Devise.debug
          attribute_data = Hash[CGI.unescape(encoded_attribute_data).split('|').collect { |el| els = el.split('='); [els[0].to_sym, els[1]]}]
          Rails.logger.warn("Attribute Data: #{attribute_data.inspect}") if Devise.debug

          authentication_info = valid_authentication_data(authentication_data, external_ip)
          return nil unless authentication_info
          return {:user_info => attribute_data, :authentication_info => authentication_info}
        end

        def valid_authentication_data(authentication_data, external_ip)
          user_id, time_stamp, user_ip, app_id, id_type = authentication_data.split('|')

          authentication_info = {
            :user_id => user_id,
            :time_stamp => time_stamp,
            :user_ip => user_ip,
            :app_id => app_id,
            :id_type => id_type
          }

          Rails.logger.warn("user_id: #{user_id} || time_stamp: #{time_stamp} || external_ip: #{external_ip} || user_ip: #{user_ip} || app_id: #{app_id} || id_type: #{id_type}") if Devise.debug

          # check against ip address.
          return false unless user_ip == external_ip

          # check for expired time_stamp
          return false if Time.parse(time_stamp).localtime + 120 < Time.now

          # check for invalid application ID
          return false if app_id != Devise.authen_application
          return authentication_info
        end

      end
    end
  end
end
