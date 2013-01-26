class Organization < ActiveRecord::Base
  attr_accessible :name, :short_name, :status
  has_many :events

  def executive_board
    # Stub for now, will return the actual email addresses of the executive
    # board members
    'ted27@case.edu'
  end
end
