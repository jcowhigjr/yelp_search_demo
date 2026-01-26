require 'application_system_test_case'

class DebugFavoriteTest < ApplicationSystemTestCase
  setup do
    stub_yelp_api_request('coffee')
    @user = users(:one)
  end

  test 'debug search results and favorite elements' do
    # Login
    visit '/login'

    assert_selector 'h1', text: 'Login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Navigate explicitly to the search page and wait for the form
    visit new_search_path
    search_box = find(:fillable_field, 'search[query]', wait: 10)
    search_box.fill_in(with: 'coffee')
    find('button[aria-label="Search"]').click

    # Wait for search results
    assert_selector '.coffeeshop-card', wait: 10

    # Check if we have at least one favorite turbo frame and button on the first card
    within first('.coffeeshop-card') do
      assert_selector "turbo-frame[id*='favorite']", wait: 10

      within "turbo-frame[id*='favorite']" do
        assert_selector 'button.favorite-btn', wait: 5
      end
    end

    # Verify we're on a search results page
    assert_match %r{/searches/\d+}, current_path
  end
end
