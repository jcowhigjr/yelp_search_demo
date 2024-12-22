# frozen_string_literal: true

require 'application_system_test_case'
require 'minitest/autorun'
require 'minitest/focus'

class LoginTest < ApplicationSystemTestCase
  setup { @user = users(:one) }

  test 'I should login and see My Profile' do
    visit '/login'
    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'menu' if ENV['CUPRITE'] == 'true'
    click_on 'My Profile'

    assert_text 'Your favorite spots:'
  end
end
