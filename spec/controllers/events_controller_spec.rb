require 'spec_helper'

DATE_FORMAT = '%-m/%-d/%Y'
TIME_FORMAT = '%-H:%M %p'

describe EventsController do
  context 'the do_import action' do
    let(:event1) { FactoryGirl.build(:event) }
    let(:event2) { FactoryGirl.build(:event) }

    let(:csv_data) { 
      [
        # Two offset rows, because CollegiateLink gives us them! How generous!
        'All Events',
        '',

        # Header Row
        [
          'Event ID',
          'Start Date',
          'Start Time',
          'End Date',
          'End Time',
          'Event Type',
        ].join(','),

        # Data Row 1
        [
          event1.id,
          event1.starts.strftime(DATE_FORMAT),
          event1.starts.strftime(TIME_FORMAT),
          event1.ends.strftime(DATE_FORMAT),
          event1.ends.strftime(TIME_FORMAT),
          'Public',
        ].join(','),

        # Data Row 2
        [
          event2.id,
          event2.starts.strftime(DATE_FORMAT),
          event2.starts.strftime(TIME_FORMAT),
          event2.ends.strftime(DATE_FORMAT),
          event2.ends.strftime(TIME_FORMAT),
          'Public',
        ].join(','),
      ].join("\n")
    }

    before do
      controller.stubs(:params).returns(
        :import => { :csv => stub(:read => csv_data) }
      )

      post :do_import
    end

    it 'creates all events successfully' do
      Event.count.should == 2
    end

    it 'assigns the collegiatelink id to the events' do
      Event.where(:collegiatelink_id => event1.id).should be_present
    end

    it 'assigns the start and end date to the events' do
      Event.where(:collegiatelink_id => event1.id).first.starts.should == event1.starts
      Event.where(:collegiatelink_id => event2.id).first.ends.should == event2.ends
    end
  end

end
