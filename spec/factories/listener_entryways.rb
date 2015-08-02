# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :listener_entryway do
    entryway
    gateway
    content
    extension
    minute Faker::Base.regexify(/[0-9]{1}/)
    called_at Time.now
  end
end
