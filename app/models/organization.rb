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
        User.where(:username => 'cpw23').first,
      ]
    when "production"
      exec_members
    end
  end

  def sync_executive_board!
    exec = COLLEGIATELINK.roster(collegiatelink_id).uniq { |m| m.id }.keep_if do |member|
      member.active_positions.keep_if { |pos| Organization.exec_titles.include?(pos.name) }.present?
    end

    self.exec_positions.destroy_all

    self.exec_positions = exec.map do |member|
      self.exec_positions.create(
        :user => User.where(:username => member.username).first_or_create(
          :collegiatelink_id => member.id,
          :firstname => member.firstname,
          :lastname => member.lastname,
          :campusemail => member.campusemail,
        ),
        :name => member.active_positions.keep_if { |pos| exec_titles.include?(pos.name) }.map(&:name).join(", ")
      )
    end
  end

  class << self
    def sync_from_collegiatelink!
      COLLEGIATELINK.organizations(:includehidden => true).each do |org|
        Organization.where(:collegiatelink_id => org.id).first_or_create.update_attributes(
          :name => org.name,
          :short_name => org.shortName,
          :status => org.status,
          :collegiatelink_url => org.siteUrl.sub('casewestern.collegiatelink.net', 'spartanlink.case.edu'),
        )
      end
    end
  end
end
