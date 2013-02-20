FactoryGirl.define do
  factory :user do
    firstname 'Colin'
    lastname 'Williams'
    sequence(:collegiatelink_id)
    sequence(:campusemail) { |n| "cpw#{n}@case.edu" }
    sequence(:username) { |n| "cpw#{n}" }

    factory :finance_team_user do
      is_finance_team true
    end
  end
end
