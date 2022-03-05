# frozen_string_literal: true

require "application_system_test_case"
require "minitest/autorun"
require "minitest/focus"

class LoginTest < ApplicationSystemTestCase

  setup do
    @user = users(:one)
  end

  test "I should login and see my profile" do
    visit '/login'
    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'My Profile'
  end
end