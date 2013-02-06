class Event < ActiveRecord::Base
  attr_accessible :starts, :ends, :title
  belongs_to :organization

  def self.states
    [ :unknown, :upcoming, :happening, :happened, :disbursement_wait ]
  end

  def self.all_states
    Event.states + [ :cancelled, :funds_reclaimed ]
  end

  def self.state_descriptions
    # TODO: Get these out of here...
    {
      :unknown => 'Distant Future (more than 2 weeks out)',
      :upcoming => 'Short-Term Future (less than 2 weeks out)',
      :happening => 'Happening Now!',
      :happened => 'Just Ended (ended less than 7 days ago)',
      :disbursement_wait => 'In Disbursement Window',
      :cancelled => 'Event Cancelled',
      :funds_reclaimed => 'Funds Reclaimed!',
    }.with_indifferent_access
  end

  def self.need_attention
    Event.all.keep_if { |x| x.state_name != x.desired_state }
  end

  # See README.md for descriptions of the states
  state_machine :state, :initial => :unknown do
    state :unknown
    state :upcoming
    state :happening
    state :happened
    state :disbursement_wait
    state :cancelled
    state :funds_reclaimed

    event :confirm do
      # The executive board has confirmed their event
    end

    event :cancel do
      # A member of the executive board (or Finance) has cancelled their event
      transition all - [ :funds_reclaimed ] => :cancelled
    end

    event :update_state! do
      transition :unknown => :upcoming, :if => lambda { |e| e.desired_state == :upcoming }
      transition :upcoming => :happening, :if => lambda { |e| e.desired_state == :happening }
      transition :happening => :happened, :if => lambda { |e| e.desired_state == :happened }
      transition :happened => :disbursement_wait, :if => lambda { |e| e.desired_state == :disbursement_wait }
    end

    event :load_state! do
      transition all => :upcoming, :if => lambda { |e| e.desired_state == :upcoming }
      transition all => :happening, :if => lambda { |e| e.desired_state == :happening }
      transition all => :happened, :if => lambda { |e| e.desired_state == :happened }
      transition all => :disbursement_wait, :if => lambda { |e| e.desired_state == :disbursement_wait }
    end

    event :reclaim_funds do
      transition all => :funds_reclaimed
    end

    after_transition :on => :update_state! do |e, t|
      e.organization.sync_executive_board! unless e.organization.executive_board.present?

      case t.to_name
      when :upcoming
        EventMailer.two_weeks_out(e).deliver
      when :happening
        EventMailer.one_day_out(e).deliver
      when :disbursement_wait
        EventMailer.one_week_after(e).deliver
      end
    end
  end

  def desired_state
    return state_name if [ :cancelled, :funds_reclaimed ].include?(state_name)

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

  def happening?
    !happened? && !in_future?
  end
end
