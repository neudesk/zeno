# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :data_content_off_air do
    content_id 1
    day 1
    time_start "2014-09-09 17:11:05"
    time_end "2014-09-09 17:11:05"
    stream_url "MyString"
  end
end
