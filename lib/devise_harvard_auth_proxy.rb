# encoding: utf-8
require 'devise'
require 'devise_harvard_auth_proxy/model'
require 'devise_harvard_auth_proxy/strategy'
require 'devise_harvard_auth_proxy/routes'

# Register as a Rails engine if Rails::Engine exists
begin
  Rails::Engine
rescue
else
  module DeviseHarvardAuthProxy
    class Engine < Rails::Engine
    end
  end
end

module Devise
 
  @@gpg_home = nil
  @@gpg_path = '/usr/bin/gpg'
  @@gpg_passphrase = nil
  @@authen_application = nil
  @@pin_url = 'https://www.pin1.harvard.edu/pin/authenticate?__authen_application='
  @@creation_attributes = Proc.new do |user,user_info,authentication_info|
    Rails.logger.warn("User in proc: #{user.inspect}")
    Rails.logger.warn("User info in proc: #{user_info.inspect}")
    Rails.logger.warn("Auth info in proc: #{authentication_info.inspect}")
    user.mail = user_info[:mail]
    user.edupersonaffiliation = user_info[:edupersonaffiliation]
    user.guid = authentication_info[:user_id]
  end
  @@identifier = :mail
  @@post_logout_url = '/'
  @@debug = false

  mattr_accessor :gpg_home, :gpg_path, :gpg_passphrase, :authen_application, :pin_url, :creation_attributes, :identifier, :post_logout_url, :debug
  
end

Devise.add_module(:harvard_auth_proxy_authenticatable,
                  :route => :harvard_auth_proxy_authenticatable,
                  :controller => :hauthproxy,
                  :strategy   => true,
                  :model  => 'devise_harvard_auth_proxy/model')
