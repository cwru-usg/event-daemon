class Organization < ActiveRecord::Base
  attr_accessible :name, :short_name, :status
  has_many :events
end
