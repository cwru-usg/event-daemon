class UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [ :login ]
  before_filter :require_finance_team, :except => [ :login, :logout ]

  def index
    @users = Hash.new([]).merge(User.all.group_by { |u| !!u.is_finance_team })
  end

  def create
    @user = User.where(:username => params[:user][:username]).first_or_create(
      :campusemail => "#{params[:user][:username]}@case.edu"
    )

    redirect_to users_url
  end

  def show
    @user = User.find(params[:id])
  end

  def grant_finance_team
    @user = User.find(params[:id])
    @user.update_attribute(:is_finance_team, true)

    redirect_to users_url
  end

  def revoke_finance_team
    @user = User.find(params[:id])
    @user.update_attribute(:is_finance_team, false)

    redirect_to users_url
  end

  def login
    redirect_to root_url
  end

  def logout
    session.delete(:cas_user)
    redirect_to root_url
  end
end
