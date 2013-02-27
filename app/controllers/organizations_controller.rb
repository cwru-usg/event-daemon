class OrganizationsController < ApplicationController
  before_filter :require_finance_team

  def index
    @orgs = Organization.all
  end

  def show
    @org = Organization.find(params[:id])
  end

  def sync
    Organization.sync_from_collegiatelink!

    redirect_to :organizations
  end

  def sync_exec
    @org = Organization.find(params[:id])
    @org.sync_executive_board!
    render :partial => "events/exec_list", :locals => { :organization => @org }
  end
end
