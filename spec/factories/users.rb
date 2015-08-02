# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'
FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| (Faker::Internet.email + "#{n}" )}
    pass = Faker::Base.regexify(/[a-z0-9]{16}/)
    password pass
    password_confirmation pass
  end
end
