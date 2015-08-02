# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :data_gateway do
    association :data_group_country, factory: :data_group_country
  end
end
