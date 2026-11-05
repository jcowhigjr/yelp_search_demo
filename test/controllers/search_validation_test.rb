require 'test_helper'

class SearchValidationTest < ActionDispatch::IntegrationTest
  setup do
    Coffeeshop.stubs(:configured_api_key).returns('test-key')
    @business = {
      'id' => 'wn3SJ0eu56zsU3x3dRZsgw', 'name' => 'WFM Coffee Bar', 'rating' => 0.0,
      'url' => 'https://yelp.com/test', 'image_url' => 'https://example.com/image.jpg',
      'display_phone' => '(555) 123-4567',
      'location' => { 'display_address' => ['81 S Elliot Rd', 'Chapel Hill, NC 27514'] }
    }
  end

  test 'create saves a Yelp business with the captured zero rating' do
    RestClient::Request.stubs(:execute).returns({ businesses: [@business] }.to_json)

    assert_difference('Search.count', 1) do
      post searches_path, params: { search: { query: 'coffee ', latitude: 35.933449, longitude: -79.029773 } }
    end

    assert_redirected_to search_url(Search.last)
    assert_in_delta 0.0, Search.last.coffeeshops.first.rating
    assert_equal Search.last.id, OutcomeEvent.where(event_type: 'search_success').order(:id).last.payload['search_id']
  end

  test 'create reports an invalid associated business without recording success' do
    @business['location']['display_address'] = []
    RestClient::Request.stubs(:execute).returns({ businesses: [@business] }.to_json)

    assert_no_difference(['Search.count', 'OutcomeEvent.where(event_type: "search_success").count']) do
      assert_difference('OutcomeEvent.where(event_type: "search_error").count', 1) do
        post searches_path, params: { search: { query: 'coffee', latitude: 0, longitude: 0 } }
      end
    end

    assert_redirected_to static_home_url
    assert_equal I18n.t('error.something_went_wrong'), flash[:error]
    event = OutcomeEvent.where(event_type: 'search_error').order(:id).last

    assert_equal 'validation_error', event.payload['error_category']
  end
end
