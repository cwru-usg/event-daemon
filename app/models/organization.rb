class Organization < ActiveRecord::Base
  attr_accessible :name, :short_name, :status, :collegiatelink_url
  has_many :events
  has_many :exec_positions, :class_name => CurrentPosition
  has_many :exec_members, :through => :exec_positions, :source => :user

  cattr_accessor :exec_titles do ['President', 'Treasurer', 'Vice-President', 'Secretary', 'Primary Contact'] end

  def executive_board
    case Rails.env
    when "development"
      [
        User.where(:username => 'ted27').first,
      ]
    when "production"
      exec_members
    end
  end

  def sync_executive_board!
    exec = COLLEGIATELINK.roster(collegiatelink_id).select(&:current?).keep_if do |member|
      Organization.exec_titles.include?(member.positionName)
    end

    self.exec_positions.destroy_all

    self.exec_positions = exec.map do |member|
      self.exec_positions.create(
        :user => User.where(:username => member.username).first_or_create(
          :collegiatelink_id => member.userId,
          :firstname => member.userFirstName,
          :lastname => member.userLastName,
          :campusemail => member.userCampusEmail,
        ),
        :name => member.positionName,
      )
    end
  end

  def up_to_date?
    Time.now - updated_at < 1.day
  end

  class << self
    def sync_from_collegiatelink!
      COLLEGIATELINK.organizations.each do |org|
        Organization.where(:collegiatelink_id => org.organizationId).first_or_create.update_attributes(
          :name => org.name,
          :short_name => org.shortName,
          :status => org.status,
          :collegiatelink_url => org.profileUrl.sub('casewestern.collegiatelink.net', 'experience.case.edu'),
        )
      end
    end
  end
end
