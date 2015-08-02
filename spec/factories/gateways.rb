# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gateway do
    sequence(:name) { |n| Faker::Lorem.word+"_#{n}"}
    country
    language
  end
end
