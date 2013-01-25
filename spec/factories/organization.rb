FactoryGirl.define do
  factory :organization do
    sequence(:id)
    sequence(:collegiatelink_id)
    sequence(:name) { |x| "Organization ##{x}" }
    sequence(:short_name) { |x| "ORG#{x}" }
    status 'Active'
  end
end
