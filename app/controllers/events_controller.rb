class EventsController < ApplicationController
  before_filter :require_finance_team

  def index
    @events = Event.this_semester.includes({ :organization => :exec_members }).
      order(:starts).reverse_order

    if params[:state]
      if params[:state] == 'todo'
        @events = @events.keep_if {|e| e.state_name != e.desired_state }
      else
        @events = @events.keep_if {|e| e.state == params[:state] }
      end

      session[:last_event_index_state] = params[:state]
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.state = params[:event][:state]
    @event.reclaimed_amount = params[:event][:reclaimed_amount].to_f
    @event.error = params[:event][:error]
    @event.reclaimed_at = Time.now
    if !@event.save
      flash[:error] = "Could not perform event surgery :("
    end
    redirect_to events_url
  end


  def import; end

  def update_state
    @event = Event.find(params[:id])

    if params[:ninja] == 'true'
      @event.load_state!
    else
      @event.update_state!
    end

    redirect_to event_state_path(session[:last_event_index_state])
  end

  def reclaim_funds
    @event = Event.find(params[:id])
    @event.reclaimed_amount = params[:reclaim_amount].to_f
    @event.reclaimed_at = Time.now
    @event.save

    @event.reclaim_funds!

    redirect_to event_state_path(session[:last_event_index_state])
  end

  def cancel
    @event = Event.find(params[:id])
    @event.cancel

    redirect_to event_state_path(session[:last_event_index_state])
  end

  def do_import
    csv = params[:import][:csv].read.each_line.drop(2).join

    CSV.parse(csv, :headers => :first_row).each do |e|
      starts_date = Date.strptime(e['Start Date'], '%m/%d/%Y') # Yay America!
      ends_date = Date.strptime(e['End Date'], '%m/%d/%Y') # Yay America!

      starts = Time.parse("#{e['Start Time']}", starts_date)
      ends = Time.parse("#{e["End Time"]}", ends_date)

      org = Organization.where(:name => e['Organization']).first

      event = Event.where(:collegiatelink_id => e['Event ID']).first_or_initialize
      event.title = e['Event Title'].force_encoding('utf-8')
      just_canceled = (e['Status'] == 'Canceled')
      event.organization = org if org

      if event.starts != starts || event.ends != ends || event.canceled != just_canceled
        event.starts = starts
        event.ends = ends
        event.canceled = just_canceled
        event.save
        event.load_state!
      else
        event.save
      end
    end

    redirect_to :events
  end
end
