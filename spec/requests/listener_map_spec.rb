require 'rspec'
require 'rails_helper'

describe ListenerMap do
  map = ListenerMap.new(FactoryGirl.build(:user))
  let(:phone_list) {['12019876543', '19406543210', '13256543211', '19406534589']}
  let(:ip_list) {['107.170.144.247', '92.209.35.20', '2.24.131.123']}

  it 'should pull the area code out of a phone number' do
    expect(map.area_code_for_listener('15559876543')).to eq '555'
  end

  it 'should take a list of phone numbers and return a list of area codes' do
    expect(map.extract_area_code(phone_list)).to eq ['201', '940', '325', '940']
  end

  it 'should make an array of lat longs from phone numbers' do
    expect(map.format_phone_listeners(map.extract_area_code(phone_list)).length).to eq 2
    expect(map.format_phone_listeners(map.extract_area_code(phone_list))[:results].length).to eq 4
  end

  it 'should convert an ip to lat/long' do
    expect(map.convert_ip_lat_long('107.170.144.247').to_h).to have_key(:latitude)
  end

  it 'should make an array of lat longs from widget listeners' do
    expect(map.format_widget_listeners(ip_list).length).to eq 2
    expect(map.format_widget_listeners(ip_list)[:results].length).to eq 3
  end
end
