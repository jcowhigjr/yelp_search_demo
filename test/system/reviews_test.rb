require 'application_system_test_case'

require 'minitest/autorun'
require 'minitest/focus'

class BasicsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @coffeeshop = coffeeshops(:one)
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
    click_link_or_button 'Search'
    sleep 2 if ENV['CUPRITE'] == 'true'

    click_on 'More Info', match: :first

    # Add to favorites
    assert_selector('input[type="submit"][value="ADD TO MY FAVORITES"]')
    click_on 'ADD TO MY FAVORITES'

    # Submit a review
    fill_in 'review[content]', with: 'Great coffee!'
    click_on 'Submit Review'

    assert_text 'Great coffee!'
  end

end
