require 'application_system_test_case'

class DebugFavoriteTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test 'debug search results and favorite elements' do
    # Login
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Search for coffee
    visit '/'
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click

    # Wait for search results
    assert_selector '.coffeeshop-card', wait: 10

    # Check if we have any turbo frames
    frames = all('[id*="favorite"]')
    assert frames.count > 0, "Expected to find favorite frames"
    
    # Check if we have favorite buttons
    buttons = all('.favorite-btn')
    assert buttons.count > 0, "Expected to find favorite buttons"
    
    # Verify we're on the search results page
    assert_match %r{/searches/\d+}, current_path
  end
end
