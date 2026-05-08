# frozen_string_literal: true

require 'application_system_test_case'
# require 'minitest/autorun'
# require 'minitest/focus'

class LogoutTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @coffeeshops = coffeeshops(:one)
    @search = searches(:one)
  end

  test 'When I log out I can not leave a review' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Use viewport-aware navigation helper
    navigate_via_nav('New Search')

    assert_current_path '/searches/new'

    # Navigate to logout
    navigate_via_nav('Logout')

    assert_current_path '/'
    fill_in 'search_query', with: 'yoga'

    assert_selector(:field, 'search_query', with: 'yoga')
    first('button[type="submit"]').click

    assert_current_path search_path(Search.last.id, locale: nil)
    wait_for_search_results
    click_more_info_safely

    assert_text 'Login to add this shop to your favorites!'
  end
end
