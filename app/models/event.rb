class Event < ActiveRecord::Base
  attr_accessible :starts, :ends, :title
  belongs_to :organization

  scope :this_semester, lambda { where('starts > ? AND ends < ?', Time.new(2013,1,1), Time.new(2013,6,1)) }

  def self.states
    [ :unknown, :upcoming, :happening, :happened, :disbursement_wait, :disbursement_done ]
  end

  def self.all_states
    Event.states + [ :canceled, :funds_reclaimed, :error ]
  end

  def self.state_descriptions
    # TODO: Get these out of here...
    {
      :unknown => 'Distant Future (more than 2 weeks out)',
      :upcoming => 'Short-Term Future (less than 2 weeks out)',
      :happening => 'Happening Now!',
      :happened => 'Just Ended (ended less than 7 days ago)',
      :disbursement_wait => 'In Disbursement Window',
      :disbursement_done => 'Past Disbursement Window',
      :canceled => 'Event Canceled',
      :funds_reclaimed => 'Funds Reclaimed!',
      :error => 'Event State Error!',
    }.with_indifferent_access
  end

  def self.need_attention
    Event.this_semester.keep_if { |x| x.state_name != x.desired_state }
  end

  # See README.md for descriptions of the states
  state_machine :state, :initial => :unknown do
    state :unknown
    state :upcoming
    state :happening
    state :happened
    state :disbursement_wait
    state :disbursement_done
    state :canceled
    state :funds_reclaimed
    state :error

    event :confirm do
      # The executive board has confirmed their event
      # TODO: Is this a thing?
    end

    event :cancel do
      transition all => :canceled
    end

    # The normal path for an event: following an update_state!, an email will be
    # sent according to whether it is appropriate as determined by the state
    # machine.
    event :update_state! do
      transition [:unknown, :upcoming, :happening] => :unknown, :if => lambda { |e| e.desired_state == :unknown }
      transition [:unknown, :upcoming, :happening] => :upcoming, :if => lambda { |e| e.desired_state == :upcoming }
      transition [:unknown, :upcoming, :happening] => :happening, :if => lambda { |e| e.desired_state == :happening }
      transition [:unknown, :upcoming, :happening] => :happened, :if => lambda { |e| e.desired_state == :happened }
      transition [:unknown, :upcoming, :happening, :happened] => :disbursement_wait, :if => lambda { |e| e.desired_state == :disbursement_wait }
      transition all => :disbursement_done, :if => lambda { |e| e.desired_state == :disbursement_done }
    end

    after_transition :on => :update_state! do |e, t|
      case t.to_name
      when :upcoming
        EventMailer.two_weeks_out(e).deliver
      when :happening
        EventMailer.one_day_out(e).deliver
      when :disbursement_wait
        EventMailer.one_week_after(e).deliver
      end
    end

    after_failure :on => :update_state! do |e, t|
      e.update_attribute(:error, "Cannot transition from \"#{Event.state_descriptions[t.from_name]}\" to \"#{Event.state_descriptions[e.desired_state]}\"!")
      e.require_custom_email!
    end

    event :load_state! do
      transition all => :unknown, :if => lambda { |e| e.desired_state == :unknown }
      transition all => :upcoming, :if => lambda { |e| e.desired_state == :upcoming }
      transition all => :happening, :if => lambda { |e| e.desired_state == :happening }
      transition all => :happened, :if => lambda { |e| e.desired_state == :happened }
      transition all => :disbursement_wait, :if => lambda { |e| e.desired_state == :disbursement_wait }
      transition all => :disbursement_done, :if => lambda { |e| e.desired_state == :disbursement_done }
    end

    event :reclaim_funds! do
      transition all => :funds_reclaimed
    end

    after_transition :on => :reclaim_funds! do |e, t|
      EventMailer.funds_reclaimed(e).deliver
    end

    event :require_custom_email! do
      transition all => :error
    end
  end

  def desired_state
    return state_name if [ :canceled, :funds_reclaimed, :error ].include?(state_name)

    return :disbursement_done if ended_more_than_two_weeks_ago? || canceled
    return :disbursement_wait if ended_more_than_a_week_ago?
    return :unknown if more_than_two_weeks_in_future?
    return :happened if happened? || (happened? && !ended_more_than_a_week_ago?)
    return :happening if happening? || less_than_one_day_in_future?
    return :upcoming
  end

  def to_s(type)
    human_fmt = '%A, %-m/%-d @ %l:%M %P'
    case type
    when :starts
      starts.strftime(human_fmt)
    when :ends
      ends.strftime(human_fmt)
    when :state
      Event.state_descriptions[state]
    when :desired_state
      Event.state_descriptions[desired_state]
    else
      super
    end
  end

  def happened?
    ends < Time.now
  end

  def in_future?
    Time.now < starts
  end

  def more_than_two_weeks_in_future?
    starts - Time.now > 2.weeks
  end

  def less_than_one_day_in_future?
    starts - Time.now < 1.day
  end

  def ended_more_than_a_week_ago?
    Time.now - ends > 1.week
  end

  def ended_more_than_two_weeks_ago?
    Time.now - ends > 2.weeks
  end

  def happening?
    !happened? && !in_future?
  end

  def up_to_date?
    Time.now - updated_at < 1.day
  end
end
