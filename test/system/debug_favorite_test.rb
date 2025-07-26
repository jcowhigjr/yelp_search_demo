require 'application_system_test_case'

class DebugFavoriteTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test 'debug search results and favorite elements' do
    # Login
    visit '/login'
    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Search for coffee
    visit '/'
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click

    # Wait for search results
    assert_selector '.coffeeshop-card', wait: 10

    # Debug: Print page content
    puts '=== PAGE HTML ==='
    puts page.html
    puts '=== END HTML ==='

    # Check if we have any turbo frames
    frames = all('[id*="favorite"]')
    puts "Found #{frames.count} favorite frames"
    
    # Check if we have favorite buttons
    buttons = all('.favorite-btn')
    puts "Found #{buttons.count} favorite buttons"
    
    # Check if logged_in? helper is working
    puts "Current path: #{current_path}"
  end
end
