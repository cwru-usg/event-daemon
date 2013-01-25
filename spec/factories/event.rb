FactoryGirl.define do
  factory :event do
    sequence(:id)
    collegiatelink_id 12345
    starts { Time.zone.now.beginning_of_hour + 2.months }
    ends { starts + 4.hours }
    sequence(:title) { |x| "Event ##{x}" }
  end
end
