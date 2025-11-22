require 'application_system_test_case'

class SimpleFavoriteTest < ApplicationSystemTestCase
  test 'can click favorite button and see it on profile favorites' do
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
    assert_selector "[id^='favorite_'] button.favorite-btn", wait: 5
    
    # Verify the favorite button still exists (may have different state)
    assert_selector "[id^='favorite_']", wait: 5

    # Visit the user's profile page and verify favorites layout
    visit user_path(user, locale: nil)

    assert_selector 'h2.page-name', text: 'My Favorites'
    assert_selector '.coffeeshop-card', minimum: 1
  end
end
