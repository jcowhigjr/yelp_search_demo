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
    fill_in 'search[query]', with: 'tacos'

    click_button 'Search'
    assert_current_path search_path(Search.last.id)
    click_on 'More Info', match: :first
    assert_text 'Login to add this shop to your favorites!'
  end
end
