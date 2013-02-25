class EventMailer < ActionMailer::Base
  default :from => 'USG VP of Finance <usg-vpfinance@case.edu>',
    :cc => 'USG Finance Events Team <usg-financeevents@case.edu>'
  layout 'email'

  def two_weeks_out(event)
    @event = event
    @event.organization.sync_executive_board!

    mail(:to => event.organization.executive_board.map(&:to_email).join(','),
         :subject => "#{@event.organization.name} Event: #{@event.title}")
  end

  def one_day_out(event)
    @event = event
    @event.organization.sync_executive_board!

    mail(:to => event.organization.executive_board.map(&:to_email).join(','),
         :subject => "#{@event.organization.name} Event: #{@event.title}")
  end

  def one_week_after(event)
    @event = event
    @event.organization.sync_executive_board!

    mail(:to => event.organization.executive_board.map(&:to_email).join(','),
         :subject => "#{@event.organization.name} Event: #{@event.title}")
  end

  def funds_reclaimed(event)
    @event = event
    @event.organization.sync_executive_board!

    mail(:to => event.organization.executive_board.map(&:to_email).join(','),
         :subject => "#{@event.organization.name} Event: #{@event.title}")
  end
end
