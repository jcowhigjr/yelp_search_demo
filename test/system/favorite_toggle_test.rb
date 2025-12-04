require 'application_system_test_case'

class FavoriteToggleTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @coffeeshop = coffeeshops(:one)
  end

  test 'logged in user can toggle favorite with contextual icons' do
    # Login
    visit '/login'
    assert_selector 'h1', text: 'Login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Search for coffee to see results with contextual icons
    visit '/'
    assert_selector 'form.search-bar-container'
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click

    # Wait for search results
    assert_selector '.coffeeshop-card', wait: 10

    # Initially should not be favorited (should show coffee icon ☕️)
    within first('.coffeeshop-card') do
      # Wait for the turbo frame to be present
      assert_selector "turbo-frame[id*='favorite']", wait: 5
      
      within "turbo-frame[id*='favorite']" do
        assert_selector 'button.favorite-btn'
        button = find('button.favorite-btn')
        assert_includes button.text, '☕️'
      end
    end

    # Click to favorite and wait for the specific frame to be updated
    # Get the frame ID first to track it specifically
    frame_id = first('.coffeeshop-card').find("turbo-frame[id*='favorite']")[:id]
    
    within "##{frame_id}" do
      find('button.favorite-btn').click
    end

    # Wait for the Turbo stream response to update the frame
    # Use has_selector to wait for the condition without raising an error
    assert has_selector?("##{frame_id}", wait: 10), "Frame #{frame_id} should still exist after first click"
    assert has_selector?("##{frame_id} button.favorite-btn", wait: 10), "Button should exist in frame #{frame_id} after first click"
    
    # Check button state after favoriting
    within "##{frame_id}" do
      assert_selector 'button.favorite-btn:not([disabled])', wait: 5
      button = find('button.favorite-btn')
      assert_includes button.text, '☕️'
    end

    # Click to unfavorite
    within "##{frame_id}" do
      find('button.favorite-btn').click
    end

    # Wait for final update and verify
    assert has_selector?("##{frame_id}", wait: 10), "Frame #{frame_id} should still exist after second click"
    assert has_selector?("##{frame_id} button.favorite-btn", wait: 10), "Button should exist in frame #{frame_id} after second click"
    
    within "##{frame_id}" do
      assert_selector 'button.favorite-btn:not([disabled])', wait: 5
      button = find('button.favorite-btn')
      assert_includes button.text, '☕️'
    end
  end

  test 'favorite icon changes based on search term' do
    # Login
    visit '/login'
    assert_selector 'h1', text: 'Login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Coffee search - should show ☕️
    visit '/'
    assert_selector 'form.search-bar-container'
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click

    assert_selector '.coffeeshop-card', wait: 10
    within first('.coffeeshop-card') do
      frame_selector = "turbo-frame[id*='favorite']"
      assert_selector frame_selector, wait: 5

      within frame_selector do
        button = find('button.favorite-btn')
        assert_includes button.text, '☕️'
      end
    end

    # Pizza search - should show 🍕
    visit '/'
    assert_selector 'form.search-bar-container'
    fill_in 'search[query]', with: 'pizza'
    find('button[type="submit"]').click

    assert_selector '.coffeeshop-card', wait: 10
    within first('.coffeeshop-card') do
      frame_selector = "turbo-frame[id*='favorite']"
      assert_selector frame_selector, wait: 5

      within frame_selector do
        button = find('button.favorite-btn')
        assert_includes button.text, '🍕'
      end
    end
  end

  test 'anonymous user does not see favorite buttons' do
    # Don't login, just search
    visit '/'
    assert_selector 'form.search-bar-container'
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click

    # Wait for search results
    assert_selector '.coffeeshop-card', wait: 10

    # Should not see any favorite frames or buttons
    assert_no_selector "turbo-frame[id*='favorite']"
    assert_no_selector 'button.favorite-btn'
  end
end
