class CurrentPosition < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  validates_presence_of :user_id
  validates_presence_of :organization_id

  attr_accessible :name, :user
end
