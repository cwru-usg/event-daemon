class OrganizationsController < ApplicationController

  def index
    @orgs = Organization.all
  end

  def show
    @org = Organization.find(params[:id])
  end

  def sync
    COLLEGIATELINK.organizations(:includehidden => true).each do |org|
      Organization.where(:collegiatelink_id => org.id).first_or_create.update_attributes(
        :name => org.name,
        :short_name => org.shortName,
        :status => org.status,
      )
    end

    redirect_to :organizations
  end
end