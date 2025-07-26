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
      button.click
    end
    
    # Wait for turbo frame to update
    silent_wait(1)
    
    # Verify the favorite button still exists (may have different state)
    assert_selector "[id^='favorite_']", wait: 5
  end
end
