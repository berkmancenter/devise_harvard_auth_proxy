if ActionController::Routing.name =~ /ActionDispatch/
  # Rails 3
  
  ActionDispatch::Routing::Mapper.class_eval do
    protected

    def devise_harvard_auth_proxy_authenticatable(mapping, controllers)
      
      Rails.logger.warn('instantiating routes') if Devise.debug
      Rails.logger.warn("Mapping: #{mapping.inspect}") if Devise.debug
      Rails.logger.warn("Controllers: #{controllers.inspect}") if Devise.debug

      get "hauthproxy/valid", :to => "#{controllers[:hauthproxy]}#valid"
      get "hauthproxy/invalid", :to => "#{controllers[:hauthproxy]}#invalid"
      get "hauthproxy/sign_in", :to => "#{controllers[:hauthproxy]}#sign_in"
      delete "hauthproxy/sign_out", :to => "#{controllers[:hauthproxy]}#sign_out"
      delete "hauthproxy/sign_out", :to => "#{controllers[:hauthproxy]}#sign_out", :as => :destroy_user_session
    end
  
  end
else
  # Rails 2
  
  ActionController::Routing::RouteSet::Mapper.class_eval do
    protected
    def harvard_auth_proxy_authenticatable(routes, mapping)
      # TODO
    end
  end
end
