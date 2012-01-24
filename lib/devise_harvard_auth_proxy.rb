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

  @@find_resource = Proc.new do |klass, user_info, authentication_info|
    klass.find(:first, :conditions => { Devise.app_unique_user_column => user_info[Devise.pin_unique_user_attribute]})
  end
  @@creation_attributes = Proc.new do |user,user_info,authentication_info|
    Rails.logger.warn("User in proc: #{user.inspect}") if Devise.debug
    Rails.logger.warn("User info in proc: #{user_info.inspect}") if Devise.debug
    Rails.logger.warn("Auth info in proc: #{authentication_info.inspect}") if Devise.debug

    user.email = user_info[:mail]
    user.edupersonaffiliation = user_info[:edupersonaffiliation]
    user.guid = authentication_info[:user_id]
  end
  @@pin_unique_user_attribute = :mail
  @@app_unique_user_column = :email
  @@post_logout_url = '/'
  @@debug = false
  @@disable_token_authenticity_checks = false

  mattr_accessor :gpg_home, :gpg_path, :gpg_passphrase, 
    :authen_application, :pin_url, :creation_attributes, 
    :pin_unique_user_attribute, :app_unique_user_column, :post_logout_url, :debug, 
    :disable_token_authenticity_checks, :find_resource
  
end

Devise.add_module(:harvard_auth_proxy_authenticatable,
                  :route => :harvard_auth_proxy_authenticatable,
                  :controller => :hauthproxy,
                  :strategy   => true,
                  :model  => 'devise_harvard_auth_proxy/model')
