class EventMailer < ActionMailer::Base
  default :from => 'ted27@case.edu'
    #:bcc => 'USG Finance Team <usg-vpfinance@case.edu>'
  layout 'email'

  def two_weeks_out(event)
    @event = event

    mail(:to => event.organization.executive_board.map(&:to_email).join(','),
         :subject => "USG Event Upcoming - #{@event}!")
  end

  def one_day_out(event)
    @event = event

    mail(:to => event.organization.executive_board.map(&:to_email).join(','),
         :subject => "USG Event Happening - #{@event}!")
  end

  def one_week_after(event)
    @event = event

    mail(:to => event.organization.executive_board.map(&:to_email).join(','),
         :subject => "USG Event Happened - #{@event}!")
  end
end
