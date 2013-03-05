class WelcomeController < ApplicationController
  def index
    @statistics = {
      :num_events => Event.count,
      :num_organizations => Organization.count,
      :total_reclaimed => Event.sum(:reclaimed_amount),
      :total_reclaimed_canceled_events => Event.where('reclaimed_amount IS NOT NULL AND canceled = ?', true).count,
      :total_reclaimed_events => Event.where('reclaimed_amount IS NOT NULL AND canceled = ?', false).count,
    }
  end
end
