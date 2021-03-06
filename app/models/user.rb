class User < ActiveRecord::Base
  attr_accessible :firstname, :lastname, :campusemail, :username,
    :collegiatelink_id

  has_many :current_positions
  has_many :organizations, :through => :current_positions

  def name
    if firstname.present? && lastname.present?
      return "#{firstname} #{lastname}"
    else
      return username
    end
  end

  def to_email
    "#{name} <#{campusemail}>"
  end
end
