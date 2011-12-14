class Devise::HauthproxyController < Devise::SessionsController
  unloadable

  def valid
    warden.authenticate!(:scope => resource_name)
    redirect_to((params[:_redirect_to].empty?) ? '/' : params[:_redirect_to])
  end
  
  def invalid
    # urm - error from the pin system.
  end

  def sign_in
    redirect_to("#{Devise.pin_url}#{Devise.authen_application}&_redirect_to=" + CGI.escape("#{params[:_redirect_to]}"))
  end

  def sign_out
    reset_session
    redirect_to((Devise.post_logout_url.empty?) ? '/' : Devise.post_logout_url)
  end

end
