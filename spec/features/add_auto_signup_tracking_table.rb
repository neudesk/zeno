require 'spec_helper'
require 'rails_helper'

feature 'Auto Signup Tracking Table', :js => true do
  before do
    visit('/')
    fill_in('user_email', :with => 'admin@zenoradio.com')
    fill_in('user_password', :with => 'password')
    click_button 'Login'
  end

  feature 'on the pending users page', :js => true do
    before do
      visit('/pending_users/')
    end

    scenario 'should have auto-signup tab' do
      page.should have_content('Auto Sign-ups')
    end

    scenario 'should be able to pop up the signup tab' do
      click_on 'Auto Sign-ups'
      page.should have_content('Sign-ups Tracking Page')
      expect(page).to have_selector('table', count: 1)
    end

    # scenario 'should be able to view pending users account page' do
    #   click_on 'Auto Sign-ups'
    #   first(:link, 'View').click
    # end

  end

end