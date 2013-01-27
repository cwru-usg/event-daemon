class Organization < ActiveRecord::Base
  attr_accessible :name, :short_name, :status
  has_many :events
  has_many :exec_positions, :class_name => CurrentPosition
  has_many :exec_members, :through => :exec_positions, :source => :user

  def executive_board
    # Stub for now, will return the actual email addresses of the executive
    # board members
    User.where(:firstname => 'Thomas', :lastname => 'Dooner').all
  end

  def sync_executive_board!
    exec_titles = ['President', 'Treasurer', 'Vice-President', 'Secretary', 'Primary Contact']

    exec = COLLEGIATELINK.roster(collegiatelink_id).uniq { |m| m.id }.keep_if do |member|
      member.active_positions.keep_if { |pos| exec_titles.include?(pos.name) }.present?
    end

    self.exec_positions.destroy_all

    self.exec_positions = exec.map do |member|
      self.exec_positions.create(
        :user => User.where(:collegiatelink_id => member.id).first_or_create(
          :firstname => member.firstname,
          :lastname => member.lastname,
          :campusemail => member.campusemail,
          :username => member.username,
        ),
        :name => member.active_positions.keep_if { |pos| exec_titles.include?(pos.name) }.map(&:name).join(", ")
      )
    end
  end
end
