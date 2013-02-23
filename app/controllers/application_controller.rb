class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_time_zone
  before_filter :setup

  def setup
    @num_wrong_state = Event.need_attention.count
    @num_to_reclaim = Event.this_semester.where(:state => :disbursement_done).count
    @logged_in_user = (session[:cas_user].present?) ? User.where(:username => session[:cas_user]).first_or_create : nil
  end

  def set_time_zone
    Time.zone = 'Eastern Time (US & Canada)'
  end

  def require_login
    if !!@logged_in_user
      redirect_to root_url, :alert => 'You must be signed in to see that page'
    end
  end

  def require_finance_team
    if !@logged_in_user.try(:is_finance_team)
      redirect_to root_url, :alert => 'You must be a member of finance team to see that page!'
    end
  end
end
