module ApplicationHelper
  def logged_in?
    !!session[:cas_user]
  end

  def current_user
    logged_in? ? session[:cas_user] : 'Unknown'
  end
end
