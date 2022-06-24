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
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'menu' if ENV['CUPRITE'] == 'true'
    # this breaks without the main is the main content area
    click_on 'New Search'
    assert_current_path '/searches/new'
    click_on 'menu' if ENV['CUPRITE'] == 'true'
    click_on 'Logout'
    assert_current_path '/'

    # there is a bug in the system that causes filling in search to not work sometimes
    assert_selector(:field, 'search_query', with: '', visible: false)

    fill_in 'search_query', with: 'yoga'

    assert_selector(:field, 'search_query', with: 'yoga')
    click_on 'search'
    assert_text 'MORE INFO'
    assert_text 'Top Rated Searches for yoga near you'
    assert_current_path search_path(Search.last.id, locale: nil)
    click_on 'More Info', match: :first
    assert_text 'Login to add this shop to your favorites!'
  end
end
