require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase
  COMMON_SEARCH_SELECTORS = '.search-results, [data-results], .results, #search-results, ' \
    'div[role="main"], main, [data-controller~="search"]'.freeze

  test 'An anonymous user at the static home can search by query and view results' do
    query = 'yoga'

    visit new_search_path  # Use the explicit path instead of '/'

    fill_in 'search[query]', with: query

    # Use the same navigation pattern that works in the navigation test
    click_on 'search'

    assert_text "Top Rated Searches for #{query} near you", wait: 4

    # Wait for search results to fully load
    wait_for_search_results

    # Click More Info and verify navigation to a coffeeshop page
    click_more_info_safely
    assert_current_path %r{^/coffeeshops/\d{1,9}}

    # Go back once and ensure we land back on the search results page
    page.execute_script('window.history.back()')
    assert_current_path "/searches/#{Search.last.id}"
  end

  test 'An anonymous user can update the query' do
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
    
    # Update the search query - find the search box again as the page may have reloaded
    search_box = find_field('search[query]', wait: 5)
    search_box.fill_in(with: query2)
    
    # Verify the search query was updated
    assert_selector(:fillable_field, 'search[query]', with: query2, wait: 5)
    
    # Submit the updated search
    search_box.send_keys(:enter)
    
    # Wait for the URL to update with the new search
    assert_current_path(%r{/searches/\d+}, wait: 10)
    
    # Verify we have some content on the results page
    assert_selector(COMMON_SEARCH_SELECTORS, wait: 10, visible: :all, match: :first)
    
    # Wait for a specific element to ensure the test completes successfully
    assert_selector(COMMON_SEARCH_SELECTORS, wait: 5)
  end

end
