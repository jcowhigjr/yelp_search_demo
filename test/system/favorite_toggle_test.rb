require 'application_system_test_case'

class FavoriteToggleTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @coffeeshop = coffeeshops(:one)
  end

  test 'logged in user can toggle favorite with contextual icons' do
    # Login
    visit '/login'
    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Search for coffee to see results with contextual icons
    visit '/'
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click

    # Wait for search results
    assert_selector '.coffeeshop-card', wait: 10

    # Find the favorite button turbo frame
    favorite_frame = first("[id^='favorite_']")
    
    # Initially should not be favorited (should show coffee icon ☕️)
    within favorite_frame do
      assert_selector 'button.favorite-btn'
      button = find('button.favorite-btn')

      assert_includes button.text, '☕️'
    end

    # Click to favorite
    within favorite_frame do
      find('button.favorite-btn').click
    end

    # Wait for Turbo Frame to update
    sleep 0.5

    # Should now be favorited (still coffee icon but different state) - find frame again
    favorite_frame = first("[id^='favorite_']")
    within favorite_frame do
      assert_selector 'button.favorite-btn'
      button = find('button.favorite-btn')

      assert_includes button.text, '☕️'
    end

    # Click to unfavorite - find frame again after update
    favorite_frame = first("[id^='favorite_']")
    within favorite_frame do
      find('button.favorite-btn').click
    end

    # Wait for Turbo Frame to update
    sleep 0.5

    # Should be back to unfavorited state - find frame again
    favorite_frame = first("[id^='favorite_']")
    within favorite_frame do
      assert_selector 'button.favorite-btn'
      button = find('button.favorite-btn')

      assert_includes button.text, '☕️'
    end
  end

  test 'favorite icon changes based on search term' do
    # Login
    visit '/login'
    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Test coffee search - should show ☕️
    visit '/'
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click
    
    assert_selector '.coffeeshop-card', wait: 10
    favorite_frame = first("[id^='favorite_']")
    within favorite_frame do
      button = find('button.favorite-btn')

      assert_includes button.text, '☕️'
    end

    # Test pizza search - should show 🍕
    visit '/'
    fill_in 'search[query]', with: 'pizza'
    find('button[type="submit"]').click
    
    assert_selector '.coffeeshop-card', wait: 10
    favorite_frame = first("[id^='favorite_']")
    within favorite_frame do
      button = find('button.favorite-btn')

      assert_includes button.text, '🍕'
    end

    # Test taco search - should show 🌮
    visit '/'
    fill_in 'search[query]', with: 'taco'
    find('button[type="submit"]').click
    
    assert_selector '.coffeeshop-card', wait: 10
    favorite_frame = first("[id^='favorite_']")
    within favorite_frame do
      button = find('button.favorite-btn')

      assert_includes button.text, '🌮'
    end

    # Test generic search - should show ❤️
    visit '/'
    fill_in 'search[query]', with: 'restaurant'
    find('button[type="submit"]').click
    
    assert_selector '.coffeeshop-card', wait: 10
    favorite_frame = first("[id^='favorite_']")
    within favorite_frame do
      button = find('button.favorite-btn')

      assert_includes button.text, '❤️'
    end
  end

  test 'anonymous user does not see favorite buttons' do
    # Don't login, just search
    visit '/'
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click

    # Wait for search results
    assert_selector '.coffeeshop-card', wait: 10

    # Should not see any favorite buttons
    assert_no_selector "[id^='favorite_']"
    assert_no_selector 'button.favorite-btn'
  end
end
