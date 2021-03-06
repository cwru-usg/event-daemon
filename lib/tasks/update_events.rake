namespace :usg do
  desc "Update all events"
  task :update_events => :environment do
    Event.need_attention.each do |e|
      e.update_state!
    end
  end

  desc "Sync events"
  task :sync_events => :environment do
    COLLEGIATELINK.events(startdate: Event.beginning_of_semester, enddate: Event.end_of_semester).each do |event|
      org = Organization.where(collegiatelink_id: event.organizationId).first
      starts = Time.at(event.startDateTime.to_i / 1000)
      ends = Time.at(event.endDateTime.to_i / 1000)
      just_canceled = (event.status == "Canceled")

      ev = Event.where(collegiatelink_id: event.eventId).first_or_initialize
      ev.title = event.eventName
      ev.organization = org if org

      if ev.starts != starts || ev.ends != ends || ev.canceled != just_canceled
        ev.starts = starts
        ev.ends = ends
        ev.canceled = just_canceled
        ev.save
        ev.load_state!
      else
        ev.save
      end
    end
  end

  desc "Update all events without sending emails"
  task :update_events_without_email => :environment do
    Event.need_attention.each do |e|
      e.load_state!
    end
  end
end
