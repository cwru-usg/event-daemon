namespace :usg do
  desc "Update all events"
  task :update_events => :environment do
    Event.need_attention.each do |e|
      e.update_state!
    end
  end
end
