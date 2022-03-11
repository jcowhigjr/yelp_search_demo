# frozen_string_literal: true

require "application_system_test_case"
require "minitest/autorun"
require "minitest/focus"

class LogoutTest < ApplicationSystemTestCase

  setup do
    @user = users(:one)
    @coffeeshops = coffeeshops(:one)
    @search = searches(:one)
  end

  test 'When I log out I can not leave a review' do


    visit '/login'

    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'My Profile'
    click_link 'Search'
    click_on 'Logout'
    fill_in 'query', with: 'tacos'

    if ENV['SHOW_TESTS']  && !ENV['CUPRITE']
      # sleeping for a second to allow the geolocation api call to complete
      sleep 3
      # need to stub the geolocation api call default is 0.0
      assert_no_selector(:field, 'latitude', type: 'hidden', with: '0.0')
      assert_no_selector(:field, 'longitude', type: 'hidden', with: '0.0')

    else
      # use default geolocation values
      assert_selector(:field, 'latitude', type: 'hidden', with: '0.0')
      assert_selector(:field, 'longitude', type: 'hidden', with: '0.0')
    end
    click_button 'Search'

    click_on 'More Info', match: :first
    assert_text 'You must be logged in to leave a review!'
  end
end
