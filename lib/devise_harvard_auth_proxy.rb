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
  @@user_attributes = ['user_id','time_stamp','app_id','id_type']
  @@identifier = 'mail'

  mattr_accessor :gpg_home, :gpg_path, :gpg_passphrase, :authen_application, :pin_url, :user_attributes, :identifier
  
end

Devise.add_module(:harvard_auth_proxy_authenticatable,
                  :route => :harvard_auth_proxy_authenticatable,
                  :controller => :hauthproxy,
                  :strategy   => true,
                  :model  => 'devise_harvard_auth_proxy/model')
