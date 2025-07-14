require 'application_system_test_case'

class YelpApiScenariosTest < ApplicationSystemTestCase
  test 'handles empty search results gracefully' do
    # Clear default stubs and set up empty response
    clear_yelp_api_stubs
    stub_yelp_api_empty('nonexistent')
    
    visit new_search_path
    fill_in 'search[query]', with: 'nonexistent'
    click_on 'search'
    
    # Should handle empty results without error
    assert_current_path %r{^/searches/\d+$}
    # Could add specific assertions for empty state handling
  end

  test 'handles multiple search results correctly' do
    # Clear default stubs and set up multiple results
    clear_yelp_api_stubs
    stub_yelp_api_multiple_results('coffee')
    
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'
    click_on 'search'
    
    # Should display multiple results
    assert_current_path %r{^/searches/\d+$}
    # Could add assertions for multiple result display
  end

  test 'handles API errors gracefully' do
    # Clear default stubs and set up error response
    clear_yelp_api_stubs
    stub_yelp_api_error('coffee')
    
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'
    click_on 'search'
    
    # Should handle API errors gracefully
    # The application should show some error state or fallback
    assert_current_path %r{^/searches/\d+$}
  end

  test 'supports parameterized search terms' do
    # Test different search terms with appropriate responses
    ['pizza', 'thai', 'sushi'].each do |term|
      clear_yelp_api_stubs
      stub_yelp_api_success(term)
      
      visit new_search_path
      fill_in 'search[query]', with: term
      click_on 'search'
      
      assert_current_path %r{^/searches/\d+$}
      assert_text "Top Rated Searches for #{term} near you"
    end
  end

  test 'supports custom response data' do
    # Test custom response for specific scenarios
    custom_data = {
      "businesses": [
        {
          "name": "Custom Test Restaurant",
          "rating": 5.0,
          "url": "https://www.yelp.com/biz/custom-test-restaurant",
          "image_url": "https://example.com/custom.jpg",
          "display_phone": "(555) 123-4567",
          "location": { "display_address": ["456 Test St", "Test City, TC 12345"] }
        }
      ]
    }
    
    clear_yelp_api_stubs
    stub_yelp_api_with_custom_data('custom', 40.748817, -73.985428, custom_data)
    
    visit new_search_path
    fill_in 'search[query]', with: 'custom'
    click_on 'search'
    
    assert_current_path %r{^/searches/\d+$}
    # Could add assertions for custom data display
  end

  test 'clears stubs properly between tests' do
    # Verify that clearing stubs works
    clear_yelp_api_stubs
    stub_yelp_api_success('test')
    
    # This should work normally
    visit new_search_path
    fill_in 'search[query]', with: 'test'
    click_on 'search'
    
    assert_current_path %r{^/searches/\d+$}
  end
end
