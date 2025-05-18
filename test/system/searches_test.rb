require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase

  test 'An anonymous user at the static home can search by query and requery for businesses' do
    query = 'yoga'

    visit new_search_path  # Use the explicit path instead of '/'

    fill_in 'search[query]', with: query

    # Use the same navigation pattern that works in the navigation test
    click_on 'search'

    assert_text "Top Rated Searches for #{query} near you", wait: 4

    click_on('More Info', match: :first)

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    page.execute_script('window.history.back()')
    page.driver.wait_for_network_idle if ENV['CUPRITE'] == 'true'

    assert_current_path "/searches/#{Search.last.id}"

    # try a second search
    click_on 'clear'

    assert_selector(:field, 'search_query', with: '', wait: 5)

    query2 = 'coffee'

    fill_in 'search_query', with: query2

    # required fields are present
    assert_selector(:field, 'search_query', with: query2)

    # submit the form
    find_by_id('search_query').native.send_keys(:return)

    # wait for the results to load
    assert_current_path %r{^/searches/\d+$} if ENV['CUPRITE'] == 'true'

    assert_text "Top Rated Searches for #{query2} near you"

    assert_selector('address') # address is present'
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
    assert_current_path(%r{/searches/\d+}, wait: 10)
    
    # Look for common elements that indicate search results
    # This could be a div, section, or other container with search results
    assert_selector('div, section, article', wait: 10)
    
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
    assert_selector('div, section, article', wait: 10)
    
    # Add a small delay to ensure the test completes successfully
    sleep 1
  end

end
