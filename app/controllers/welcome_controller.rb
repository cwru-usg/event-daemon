class WelcomeController < ApplicationController
  def index
    @events = Event.where(['starts < ? AND starts > ?', Time.now + 7.days, Time.now]).includes(:organization)
  end
end
