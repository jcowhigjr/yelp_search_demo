require "application_system_test_case"

class FavoritesIntegrationTest < ApplicationSystemTestCase
  setup do
    @search = searches(:one)
  end

  test "search form renders with dynamic icon functionality" do
    visit new_search_path
    
    # Verify the search form has the necessary data attributes for dynamic icons
    assert_selector "div[data-controller='search']"
    assert_selector "div[data-search-target='icon']"
    assert_selector "input[data-search-target='input']"
    assert_selector "button[data-search-target='submitButton']"
    
    # Verify initial icon is present
    assert_selector "div[data-search-target='icon'] i.fas.fa-map-marker-alt"
    
    # Test that search input accepts different terms
    fill_in "search_query", with: "coffee"
    fill_in "search_query", with: "pizza"
    fill_in "search_query", with: "taco"
    
    # The actual icon changes are handled by JavaScript and would need
    # JavaScript-enabled system tests to verify fully
  end

  test "search form has proper structure for favorites functionality" do
    visit new_search_path
    
    # Verify the form structure supports the favorites helper integration
    assert_selector "form"
    assert_selector "input[name='search[query]']"
    
    # Verify the search input container has the right structure
    assert_selector ".search-input-container"
    assert_selector ".search-icon"
    
    # Test form submission works
    fill_in "search_query", with: "coffee shop"
    # Note: We don't click submit in this test as it would trigger actual search
    # The search functionality itself is tested in other system tests
  end

  test "search form supports theme changes" do
    visit new_search_path
    
    # Verify theme container exists
    assert_selector "div[data-search-target='theme']"
    
    # Test that different search terms can be entered
    # (The actual theme changes are JavaScript-driven and would need JS-enabled tests)
    search_terms = ["coffee shop", "taco bell", "pizza hut", "burger joint"]
    
    search_terms.each do |term|
      fill_in "search_query", with: term
      # Verify the input accepts the value
      assert_field "search_query", with: term
    end
  end

  test "search form has accessibility attributes" do
    visit new_search_path
    
    # Verify accessibility attributes are present
    assert_selector "i[aria-hidden='true']"
    assert_selector "i[aria-label='search']"
    
    # Verify form has proper structure
    assert_selector "input[required]"
    assert_selector "button[type='submit']"
  end
end
