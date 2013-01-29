module ApplicationHelper
  def logged_in?
    !!@logged_in_user
  end

  def current_user
    logged_in? ? @logged_in_user.name : 'Unknown'
  end
end
