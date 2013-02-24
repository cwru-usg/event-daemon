FactoryGirl.define do
  factory :event do
    sequence(:id)
    sequence(:collegiatelink_id)
    starts { Time.zone.now.beginning_of_hour + 2.months }
    ends { starts + 4.hours }
    sequence(:title) { |x| "Event ##{x}" }
    canceled false

    organization
  end
end
