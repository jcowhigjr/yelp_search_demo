# frozen_string_literal: true

require 'application_system_test_case'
# require 'minitest/focus'

class BasicsTest < ApplicationSystemTestCase
  def setup
    @user = users(:one)
    @review = reviews(:one)
  end

  test 'Adding a review' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Search for a shop
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'

    # Ensure search button is visible and clickable
    search_button = find_button('Search')
    search_button.scroll_to

    assert_selector('button[type="submit"]', text: 'Search', visible: true)
    search_button.click

    sleep 2 if ENV['CUPRITE'] == 'true'

    # Find and click the first More Info link
    more_info_link = find_link('More Info', match: :first)
    more_info_link.scroll_to
    more_info_link.click

    # Add to favorites
    assert_selector('input[type="submit"][value="ADD TO MY FAVORITES"]')
    click_on 'ADD TO MY FAVORITES'

    # Submit a review
    fill_in 'review[content]', with: 'Great coffee!'
    click_on 'Submit Review'

    assert_text 'Great coffee!'
  end
end
