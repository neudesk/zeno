# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reachout_tab_campaign do
    gateway_id 1
    prompt "MyString"
    generic_prompt false
    schedule_start_date "2014-03-18 09:55:39"
    schedule_end_date "2014-03-18 09:55:39"
  end
end
