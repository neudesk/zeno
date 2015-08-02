# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entryway do
    name Faker::Lorem.word 
    gateway
    sequence(:did) {Faker::Base.regexify(/[0-9]{7}/)}
    sequence(:provider) {Faker::Name.name}
  end
end
