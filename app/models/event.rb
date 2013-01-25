class Event < ActiveRecord::Base
  attr_accessible :starts, :ends, :title
  belongs_to :organization
end
