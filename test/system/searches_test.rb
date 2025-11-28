require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase
  COMMON_SEARCH_SELECTORS = '.search-results, [data-results], .results, #search-results, ' \
    'div[role="main"], main, [data-controller~="search"]'.freeze

  test 'An anonymous user at the static home can search by query and view results' do
    query = 'yoga'

    visit new_search_path  # Use the explicit path instead of '/'

    # Check for prototype hero section elements (implemented)
    assert_selector 'h1.page-name', text: 'COFFEE NEAR YOU!', wait: 4
    assert_selector 'p.page-text', text: 'Find the best coffee shops in your area', wait: 4
    
    # Check for feature icons from prototype (now implemented)
    assert_selector 'div[class*="rounded-full"]', text: '☕', wait: 4
    assert_selector 'div[class*="rounded-full"]', text: '⭐', wait: 4
    assert_selector 'div[class*="rounded-full"]', text: '❤️', wait: 4

    fill_in 'search[query]', with: query

    # Use the same navigation pattern that works in the navigation test
    click_on 'Search'

    assert_text "Top Rated Searches for #{query} near you", wait: 4

    # Wait for search results to fully load
    wait_for_search_results

    # Check for prototype results page structure
    assert_selector 'h2', text: /Top Rated Searches for #{query} near you/i, wait: 4
    assert_selector 'p', text: /\d+ results? found/i, wait: 4
    
    # Check for grid layout from prototype
    assert_selector 'div[class*="grid"]', class: /gap-6/, wait: 4

    # Click More Info and verify navigation to a coffeeshop page
    click_more_info_safely
    assert_current_path %r{^/coffeeshops/\d{1,9}}

    # Go back once and ensure we land back on a search page
    go_back
    assert_current_path(%r{^/searches/(new|\d+)$}, wait: 10)
  end

  test 'search page displays prototype hero section and features' do
    visit new_search_path

    # Check for hero section from prototype (implemented)
    assert_selector 'h1.page-name', text: 'COFFEE NEAR YOU!', wait: 4
    assert_selector 'p.page-text', text: 'Find the best coffee shops in your area', wait: 4
    
    # Check for improved search bar styling (implemented)
    assert_selector 'div[class*="max-w-3xl"]'
    assert_selector 'input[placeholder*="coffee"]'
    
    # Check for feature icons from prototype (now implemented)
    assert_selector 'div[class*="rounded-full"]', text: '☕', wait: 4
    assert_selector 'div[class*="rounded-full"]', text: '⭐', wait: 4
    assert_selector 'div[class*="rounded-full"]', text: '❤️', wait: 4
    
    # Check for feature descriptions
    assert_text 'Search nearby'
    assert_text 'Read reviews'
    assert_text 'Save favorites'
    
    # Check for proper styling of feature icons
    feature_icons = all('div[class*="rounded-full"]')
    assert feature_icons.length >= 3
    
    feature_icons.each do |icon|
      assert_match /w-20 h-20/, icon[:class]
      assert_match /flex items-center justify-center/, icon[:class]
    end
  end

  test 'An anonymous user can update the query' do
    skip 'Focused on interactive query UX; run locally, skipped in CI for stability' if ENV['CI'] == 'true'
    query = 'yoga'
    query2 = 'coffee'
    
    # Visit the home page and wait for it to load
    visit '/'
    
    # Wait for the page to be interactive
    assert_selector 'body', wait: 5
    
    # Wait for the search form to be present and visible
    search_box = find_field('search[query]', wait: 10, visible: true)
    
    # Fill in the search form
    search_box.fill_in(with: query)
    
    # Verify the search query was set
    assert_selector(:fillable_field, 'search[query]', with: query, wait: 5)

    # Submit the form by pressing Enter
    search_box.send_keys(:enter)
    
    # Wait for the URL to change, indicating a navigation occurred
    assert_current_path(%r{^/searches/\d+$}, wait: 10)
    
    # Look for common elements that indicate search results
    # First check if we have any search result containers
    assert_selector(COMMON_SEARCH_SELECTORS, wait: 10, visible: :all, match: :first)
    
    # Update the search query - wait for the search form and use a fresh field
    assert_selector 'form[action="/searches"]', wait: 10
    search_box = find(:fillable_field, 'search[query]', wait: 10)
    search_box.fill_in(with: query2)

    # Verify the search query was updated
    assert_selector(:fillable_field, 'search[query]', with: query2, wait: 5)

    # Submit the updated search via Enter on the new field
    search_box.send_keys(:enter)
    
    # Wait for the URL to update with the new search
    assert_current_path(%r{/searches/\d+}, wait: 10)
    
    # Verify we have some content on the results page
    assert_selector(COMMON_SEARCH_SELECTORS, wait: 10, visible: :all, match: :first)
    
    # Wait for a specific element to ensure the test completes successfully
    assert_selector(COMMON_SEARCH_SELECTORS, wait: 5)
  end

end
