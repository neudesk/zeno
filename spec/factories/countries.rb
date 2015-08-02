# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :country do
    sequence(:name) { |n| Faker::Lorem.word + "_#{n}"}
  end
end
