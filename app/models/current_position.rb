class CurrentPosition < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  attr_accessible :name, :user
end
