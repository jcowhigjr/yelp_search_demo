# frozen_string_literal: true

require 'application_system_test_case'
require 'minitest/autorun'
require 'minitest/focus'

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

    # Use JavaScript to click the menu
    execute_script("document.querySelector('#menu').click()")
    click_on 'New Search'

    assert_current_path '/searches/new'
    
    # Use JavaScript to click the menu again
    execute_script("document.querySelector('#menu').click()")
    click_on 'Logout'

    # After logout, we should be on /searches/new
    assert_current_path '/searches/new'

    # Fill in search query
    fill_in 'search_query', with: 'yoga'

    assert_selector(:field, 'search_query', with: 'yoga')
    
    # Use the first search button to avoid ambiguity
    first('button[type="submit"]').click

    # Wait for results to load
    sleep 2 if ENV['CUPRITE'] == 'true'

    assert_current_path search_path(Search.last.id, locale: nil)
    click_on 'More Info', match: :first

    assert_text 'Login to add this shop to your favorites!'
  end
end
