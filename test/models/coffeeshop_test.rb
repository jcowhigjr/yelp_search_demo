require 'test_helper'

class CoffeeshopTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @coffeeshop = coffeeshops(:one)
  end
  test 'coffeeshop attributes must not be empty' do
    @coffeeshop.rating = nil

    assert_not @coffeeshop.valid?
  end
  test 'coffeeshop rating must be between 1 and 5' do
    assert_predicate @coffeeshop, :valid?
    @coffeeshop.rating = 0

    assert_not @coffeeshop.valid?
    @coffeeshop.rating = 5.5

    assert_not @coffeeshop.valid?
    @coffeeshop.rating = 1.5

    assert_predicate @coffeeshop, :valid?
    @coffeeshop.rating = 1

    assert_predicate @coffeeshop, :valid?
  end

  test 'get_search_results uses local data when flag is enabled' do
    # Create a search
    search = Search.create!(query: 'coffee', latitude: 40.7128, longitude: -74.0060)
    
    # Temporarily enable local data mode by defining the configuration
    Rails.application.config.define_singleton_method(:use_local_data) { true }
    
    begin
      # Call get_search_results
      Coffeeshop.get_search_results(search)
      
      # Verify that coffeeshops were created
      assert_operator search.coffeeshops.count, :>, 0
      
      # Verify that mock data was used (should include "Local Coffee House")
      coffee_shop_names = search.coffeeshops.pluck(:name)

      assert_includes coffee_shop_names, 'Local Coffee House'
    ensure
      # Remove the temporary method
      begin
        Rails.application.config.singleton_class.send(:remove_method, :use_local_data)
      rescue StandardError
        nil
      end
    end
  end
  test 'get_search_results caches API responses' do
    # Enable caching for this test
    original_cache_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    
    begin
      # Create a search
      search = Search.create!(query: 'coffee', latitude: 40.7128, longitude: -74.0060)

      # Mock the RestClient to control API calls
      mock_response = {
        'businesses' => [
          { 'name' => 'Cached Coffee Shop', 'rating' => 4.5, 'url' => 'http://example.com', 'image_url' => '', 'display_phone' => '555-1234', 'location' => { 'display_address' => ['123 Cache St'] } }
        ]
      }.to_json

      # Expect the API to be called only once
      RestClient::Request.expects(:execute).once.returns(mock_response)

      # First call - should hit the API
      Coffeeshop.get_search_results(search)
      assert_equal 1, search.coffeeshops.count

      # Second call with same search parameters - should use the cache
      search2 = Search.create!(query: 'coffee', latitude: 40.7128, longitude: -74.0060)
      Coffeeshop.get_search_results(search2)
      # This should not trigger another API call due to caching
      
    ensure
      # Restore original cache store
      Rails.cache = original_cache_store
    end
  end
end
