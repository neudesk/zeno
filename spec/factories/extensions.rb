# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :extension do
    name Faker::Lorem.word 
    content
  end
end
