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
    skip 'This test is failing because of the geolocation api call' unless ENV['SHOW_TESTS']

    visit '/login'

    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'My Profile'
    click_link 'Search'
    click_on 'Logout'
    fill_in 'query', with: 'tacos'
    sleep 4
    click_on 'Search'
    click_on 'More Info', match: :first
    assert_text 'You must be logged in to leave a review!'
  end
end