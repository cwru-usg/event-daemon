class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [ :login ]

  def login
    redirect_to root_url
  end

  def logout
    session.delete(:cas_user)
    redirect_to root_url
  end
end
