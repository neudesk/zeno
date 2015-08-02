# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :content do
    name Faker::Lorem.word
    gateway
    country
    language
    url Faker::Internet.url
  end
end
