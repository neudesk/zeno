# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :listener do
    area_code 205 
    phone Faker::PhoneNumber.phone_number
  end
end
