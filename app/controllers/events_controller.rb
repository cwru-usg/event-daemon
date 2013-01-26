class EventsController < ApplicationController
  def index
    @events = Event.where(['starts > ?', 1.month.ago]).includes(:organization).order(:starts)
    if params[:state]
      if params[:state] == 'incorrect'
        @events = @events.keep_if {|e| e.state_name != e.desired_state }
      else
        @events = @events.keep_if {|e| e.state == params[:state] }
      end
    end
  end

  def import

  end

  def update_state
    @event = Event.find(params[:id])

    @event.update_state!

    redirect_to event_path(@event)
  end

  def show
    @event = Event.find(params[:id])
  end

  def do_import
    csv = params[:import][:csv].read.each_line.drop(2).join

    CSV.parse(csv, :headers => :first_row).each do |e|
      starts_date = Date.strptime(e['Start Date'], '%m/%d/%Y') # Yay America!
      ends_date = Date.strptime(e['End Date'], '%m/%d/%Y') # Yay America!

      starts = Time.parse("#{e['Start Time']}", starts_date)
      ends = Time.parse("#{e["End Time"]}", ends_date)

      org = Organization.where(:name => e['Organization']).first

      event = Event.where(:collegiatelink_id => e['Event ID']).first_or_initialize(
        :starts => starts,
        :ends => ends,
        :title => e['Event Title'],
      )
      event.organization = org if org

      event.save
      event.load_state!
    end

    redirect_to :events
  end
end
