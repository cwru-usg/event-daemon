class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_time_zone

  def set_time_zone
    Time.zone = 'Eastern Time (US & Canada)'
  end

  def require_login
    if !session[:cas_user]
      redirect_to root_url, :alert => 'You must be signed in to see that page'
    end
  end
end
