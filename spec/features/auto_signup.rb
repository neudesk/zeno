require 'spec_helper'

feature 'Auto Signup' do

  before do
    visit('/signup')
  end

  feature 'validate', js: true do

    before do
      click_button 'Sign Up'
    end

    scenario 'presence of email' do
      page.should have_content('You have not given a correct e-mail address')
    end

    scenario 'presence of Company / Name' do
      page.should have_content('You have not answered all required fields')
    end

    scenario 'presence of station name' do
      page.should have_content('You have not answered all required fields')
    end

  end

  feature 'should be', js: true do
    time = Time.now.getutc.to_i
    before do
      fill_in('user_email', :with => "#{time}email@mailinator.com")
      fill_in('user_name', :with => "#{time} Corp")
      fill_in('user_landline', :with => '0472242257')
      fill_in('user_signup_station_name', :with => "#{time} FM")
      fill_in('user_signup_website', :with => "http://www.#{time}stream.com")
      choose('has_stream_yes')
      fill_in('user_signup_streaming_url', :with => "http://www.#{time}stream.com:3000")
      click_button 'Sign Up'
    end

    scenario 'should successfully sign up' do
      page.should have_content('ZenoRadio Broadcaster Agreement')
    end

    scenario 'able to find the new signup' do
      visit('/')
      fill_in('user_email', :with => 'admin@zenoradio.com')
      fill_in('user_password', :with => 'password')
      click_button 'Login'
      visit('/pending_users/auto_signups')
      fill_in('filter', :with => "#{time}email@mailinator.com")
      click_button('Search')
      page.should have_content("#{time}email@mailinator.com")
    end

  end

  # feature 'global settings are able to set', js: true do
  #   before do
  #     visit('/')
  #     fill_in('user_email', :with => 'admin@zenoradio.com')
  #     fill_in('user_password', :with => 'password')
  #     click_button 'Login'
  #     click 'Account'
  #     click 'Pending Users'
  #   end
  #
  #   scenario 'CLEC provider' do
  #     select('CLOUD', 'default_signup_did_provider')
  #     click 'Account'
  #     click 'Pending Users'
  #     page.should have_content('CLOUD')
  #   end
  #
  # end

end