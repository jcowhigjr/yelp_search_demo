# frozen_string_literal: true

require 'application_system_test_case'
# require 'minitest/focus'

class ReviewsTest < ApplicationSystemTestCase
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

    # Click the search button
    assert_selector('button[type="submit"]', visible: true)
    click_on('button[type="submit"]')

    sleep 2 if ENV['CUPRITE'] == 'true'

    # Find and click the first More Info link
    assert_selector('a', text: 'MORE INFO')
    first('a', text: 'MORE INFO').click

    # # Add to favorites

    # assert_selector('input[type="submit"][value="ADD TO MY FAVORITES"]')
    # click_on 'ADD TO MY FAVORITES'

    # Submit a review
    assert_selector('input[type="submit"][value="SUBMIT REVIEW"]')
    fill_in 'review[content]', with: 'Great coffee!'
    click_on 'SUBMIT REVIEW'

    assert_text 'Great coffee!'
  end
end
