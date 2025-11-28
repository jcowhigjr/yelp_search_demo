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
  
    # In the new design, navigate using the updated navigation structure
    if ENV['CUPRITE'] == 'true'
      # Open mobile sidenav
      sidenav_trigger = find('.sidenav-trigger')
      sidenav_trigger.trigger("click")
      assert_selector '#mobile-demo', visible: true, wait: 5
      find('#mobile-demo a', text: 'New Search').trigger("click")
    else
      # Desktop navigation - click directly
      click_on 'New Search'
    end

    assert_current_path '/searches/new'
  
    # Open navigation again to access logout
    if ENV['CUPRITE'] == 'true'
      sidenav_trigger = find('.sidenav-trigger')
      sidenav_trigger.trigger("click")
      assert_selector '#mobile-demo', visible: true, wait: 5
      find('#mobile-demo a', text: 'Logout').trigger("click")
    else
      click_on 'Logout'
    end

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
