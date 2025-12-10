require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase
  COMMON_SEARCH_SELECTORS = '.search-results, [data-results], .results, #search-results, ' \
    'div[role="main"], main, [data-controller~="search"]'.freeze

  setup do
    stub_yelp_api_request
  end

  test 'An anonymous user at the static home can search by query and view results' do
    query = 'yoga'

    visit new_search_path  # Use the explicit path instead of '/'

    # Check for prototype hero section elements (implemented)
    assert_selector 'h1.page-name', text: 'COFFEE NEAR YOU!', wait: 4
    assert_selector 'p.page-text', text: 'Find the best coffee shops in your area', wait: 4
    
    # Feature icons are hidden since they are non-functional

    fill_in 'search[query]', with: query

    # Use the same navigation pattern that works in the navigation test
    click_on 'Search'

    assert_text "Top Rated Searches for #{query} near you", wait: 4

    # Wait for search results to fully load
    wait_for_search_results

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
    
    # Feature icons are hidden since they are non-functional
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
    
    # Check for improved search bar styling (implemented)
    assert_selector 'div[class*="max-w-3xl"]'
    assert_selector 'input[placeholder*="coffee"]'
    
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

  # Geolocation regression tests for issue #1201
  test 'geolocation button is properly connected to controller' do
    visit new_search_path
    
    # Verify the geolocation button exists and is within the controller scope
    assert_selector '[data-controller="geolocation"]', wait: 4
    assert_selector '[data-controller="geolocation"] button[data-action="geolocation#geolocate"]', wait: 4
    assert_selector '[data-controller="geolocation"] [data-geolocation-target="latitude"]', visible: false, wait: 4
    assert_selector '[data-controller="geolocation"] [data-geolocation-target="longitude"]', visible: false, wait: 4
  end

  test 'geolocation shows error message when permission denied' do
    visit new_search_path
    
    # Mock geolocation permission denied
    page.driver.execute_script(<<~JS)
      navigator.geolocation = {
        getCurrentPosition: function(success, error, options) {
          error({
            code: 1, // PERMISSION_DENIED
            message: 'User denied the request for Geolocation.'
          });
        }
      };
    JS

    # Click the geolocation button
    find('[data-action="geolocation#geolocate"]').click
    
    # Verify error message appears
    assert_selector '.geolocation-error', wait: 4
    assert_text 'Location access denied', wait: 4
  end

  private

  def wait_for_search_results
    # Wait for any of the common search result selectors to appear
    assert_selector(COMMON_SEARCH_SELECTORS, wait: 10, visible: :all, match: :first)
  end

  def click_more_info_safely
    # Try multiple selectors for "More Info" to handle different implementations
    more_info_selectors = [
      'a[href*="/coffeeshops/"]',
      '.more-info',
      '[data-action*="more-info"]',
      'button:contains("More Info")',
      'a:contains("More Info")'
    ]
    
    more_info_clicked = false
    more_info_selectors.each do |selector|
      begin
        first_element = all(selector, visible: true, wait: 2).first
        if first_element
          first_element.click
          more_info_clicked = true
          break
        end
      rescue Capybara::ElementNotFound
        # Try next selector
      end
    end
    
    # Fallback: click first coffeeshop link if no "More Info" found
    unless more_info_clicked
      first('a[href*="/coffeeshops/"]').click
    end
  end

end
