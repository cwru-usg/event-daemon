FactoryGirl.define do
  factory :event do
    sequence(:id)
    sequence(:name) { |x| "Event ##{x}" }
    collegiatelink_id 12345
    starts { Time.zone.now.beginning_of_hour + 2.months }
    ends { starts + 4.hours }
  end
end
