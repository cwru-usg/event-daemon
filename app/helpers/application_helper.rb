module ApplicationHelper
  def logged_in?
    !!@user
  end

  def current_user
    logged_in? ? @user.name : 'Unknown'
  end
end
