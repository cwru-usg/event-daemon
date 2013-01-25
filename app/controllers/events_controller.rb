class EventsController < ApplicationController
  def import

  end

  def do_import
    csv = params[:import][:csv].read.each_line.drop(2).join

    CSV.parse(csv, :headers => :first_row).each do |e|
      starts_date = Date.strptime(e['Start Date'], '%m/%d/%Y') # Yay America!
      ends_date = Date.strptime(e['End Date'], '%m/%d/%Y') # Yay America!

      starts = Time.parse("#{e['Start Time']}", starts_date)
      ends = Time.parse("#{e["End Time"]}", ends_date)

      Event.where(:collegiatelink_id => e['Event ID']).first_or_create.update_attributes(
        :starts => starts,
        :ends => ends,
      )
    end

    render :text => Event.all.inspect
  end
end
