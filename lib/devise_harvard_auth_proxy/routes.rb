if ActionController::Routing.name =~ /ActionDispatch/
  # Rails 3
  
  ActionDispatch::Routing::Mapper.class_eval do
    protected

    def devise_harvard_auth_proxy_authenticatable(mapping, controllers)
      
      Rails.logger.warn('instantiating routes')
      Rails.logger.warn("Mapping: #{mapping.inspect}")
      Rails.logger.warn("Controllers: #{controllers.inspect}")

      get "hauthproxy/valid", :to => "#{controllers[:hauthproxy]}#valid"
      get "hauthproxy/invalid", :to => "#{controllers[:hauthproxy]}#invalid"
      post "hauthproxy/logout", :to => "#{controllers[:hauthproxy]}#logout"
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
