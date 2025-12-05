require 'application_system_test_case'

class SimpleFavoriteTest < ApplicationSystemTestCase
  test 'can click favorite button and see it on profile favorites' do
    user = users(:one)
    
    visit '/login'
    assert_selector 'h1', text: 'Login'
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
    assert_text 'Your favorite spots:'
    
    # Check for grid layout from prototype
    assert_selector 'div[class*="grid"]', class: /gap-6/, wait: 4
    assert_selector '.coffeeshop-card', minimum: 1
  end

  test 'favorites page displays prototype empty state' do
    user = users(:one)
    
    # Login as user with no favorites
    visit '/login'
    assert_selector 'h1', text: 'Login'
    fill_in 'email', with: user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    
    # Remove any existing favorites
    user.user_favorites.destroy_all
    
    # Visit profile page
    visit user_path(user, locale: nil)
    
    # Check for prototype empty state
    assert_selector 'h2.page-name', text: 'My Favorites'
    assert_text 'You haven\'t added any favorites yet'
    assert_selector 'a.form-link', text: 'Start searching for coffee shops'
    
    # Verify the link goes to search page
    click_link 'Start searching for coffee shops'
    assert_current_path new_search_path
  end
end
