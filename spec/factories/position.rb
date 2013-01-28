FactoryGirl.define do
  factory :current_position do
    name 'Member'

    user
    organization
  end
end
