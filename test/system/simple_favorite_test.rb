require 'application_system_test_case'

class SimpleFavoriteTest < ApplicationSystemTestCase
  test 'can click favorite button' do
    user = users(:one)
    
    visit '/login'
    fill_in 'email', with: user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    
    # Navigate to search page after login
    visit new_search_path
    
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click
    
    assert_selector '.coffeeshop-card', wait: 10
    
    # Find and click the favorite button
    favorite_frame = first("[id^='favorite_']")
    within favorite_frame do
      button = find('button.favorite-btn')
      puts "Before click: #{button.text}"
      button.click
    end
    
    # Wait and check what happened
    sleep 2
    puts 'Page HTML after click:'
    puts page.html
    
    # Try to find the frame again
    if has_selector?("[id^='favorite_']")
      puts 'Frame still exists'
    else
      puts 'Frame disappeared'
    end
  end
end
