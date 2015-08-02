# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reports do
    report_date "2014-02-03"
    report_hour 1
    new_users ""
    sessions ""
    total_minutes ""
    users_by_time ""
    gateway_id 1
  end
end
