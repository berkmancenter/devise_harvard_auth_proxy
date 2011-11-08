class Devise::HauthproxyController < Devise::SessionsController
  def valid
    warden.authenticate!(:scope => resource_name)
  end
  
  def invalid
  end

  def logout
  end

end
