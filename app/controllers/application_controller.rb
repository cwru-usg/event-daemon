class ApplicationController < ActionController::Base
  protect_from_forgery

  def require_login
    if !session[:cas_user]
      redirect_to root_url, :alert => 'You must be signed in to see that page'
    end
  end
end
