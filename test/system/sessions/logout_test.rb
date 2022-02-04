# frozen_string_literal: true

require "application_system_test_case"
require "minitest/autorun"
require "minitest/focus"

class LogoutTest < ApplicationSystemTestCase

  setup do
    @user = users(:one)
  end

  test "When I log out I can not leave a review" do
    visit '/login'
    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'person My Profile'
    click_on 'Search'
    click_on 'Logout'
    fill_in 'query', with: '30312'
    click_on 'Search'
    click_on 'More Info', match: :first
    assert_text 'You must be logged in to leave a review!'
  end
end
