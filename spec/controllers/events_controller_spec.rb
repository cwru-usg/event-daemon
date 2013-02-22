require 'spec_helper'

DATE_FORMAT = '%-m/%-d/%Y'
TIME_FORMAT = '%-H:%M %p'

describe EventsController do
  context 'the do_import action' do
    let!(:org) { FactoryGirl.create(:organization) }
    let!(:event1) { FactoryGirl.build(:event, :organization => org) }
    let!(:event2) { FactoryGirl.build(:event, :organization => org) }

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
          'Event Title',
          'Organization',
        ].join(','),

        # Data Row 1
        [
          event1.id,
          event1.starts.strftime(DATE_FORMAT),
          event1.starts.strftime(TIME_FORMAT),
          event1.ends.strftime(DATE_FORMAT),
          event1.ends.strftime(TIME_FORMAT),
          'Public',
          event1.title,
          org.name,
        ].join(','),

        # Data Row 2
        [
          event2.id,
          event2.starts.strftime(DATE_FORMAT),
          event2.starts.strftime(TIME_FORMAT),
          event2.ends.strftime(DATE_FORMAT),
          event2.ends.strftime(TIME_FORMAT),
          'Public',
          event2.title,
          org.name,
        ].join(','),
      ].join("\n")
    }

    before do
      controller.stubs(:params).returns(
        :import => { :csv => stub(:read => csv_data) }
      )
      controller.stubs(:session => { :cas_user => FactoryGirl.create(:finance_team_user).username })
    end

    context 'with no existing events' do
      before do
        post 'do_import'
      end

      it 'creates all events successfully' do
        Event.count.should == 2
      end

      it 'assigns the collegiatelink id to the events' do
        Event.where(:collegiatelink_id => event1.collegiatelink_id).
          should be_present
      end

      it 'assigns the start and end date to the events' do
        Event.where(:collegiatelink_id => event1.collegiatelink_id).first.
          starts.should == event1.starts
        Event.where(:collegiatelink_id => event2.collegiatelink_id).first.
          ends.should == event2.ends
      end

      it 'assigns the title to the events' do
        Event.where(:collegiatelink_id => event1.collegiatelink_id).first.
          title.should == event1.title
      end

      it 'associates the event with its parent organization' do
        Event.where(:collegiatelink_id => event1.collegiatelink_id).first.
          organization.should == org
      end
    end
    context 'with an event with the same date' do
      let!(:old_title) { event1.title }

      before do
        event1.title = 'Some older title...'
        event1.save
      end

      it 'updates the title of the event' do
        post 'do_import'

        Event.where(:collegiatelink_id => event1.collegiatelink_id).first.title.
          should == old_title
      end

      it "should not load the event's state" do
        Event.any_instance.expects(:load_state!).never
      end
    end

    context 'with an event with different dates' do
      let!(:old_start) { event1.starts }
      let!(:old_ends) { event1.ends }

      before do
        event1.starts = event1.starts - 1.day
        event1.ends = event1.ends - 1.day
        event1.save
        event2.save
      end

      it 'updates the start and end dates of the event' do
        post 'do_import'

        Event.where(:collegiatelink_id => event1.collegiatelink_id).first.
          starts.should == old_start
        Event.where(:collegiatelink_id => event1.collegiatelink_id).first.
          ends.should == old_ends
      end

      it "should load the event's state" do
        event1.expects(:load_state!)
        Event.stubs(:where => stub(:first_or_initialize => event1, :count => 0))

        post 'do_import'
      end
    end
  end
end
