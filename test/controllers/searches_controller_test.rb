require 'test_helper'

class SearchesControllerTest < ActionDispatch::IntegrationTest
  MOCK_API_RESPONSE = {
    'businesses' => [
      {
        'name' => 'Test Coffee Shop',
        'rating' => 4.5,
        'url' => 'https://yelp.com/test',
        'image_url' => 'https://example.com/image.jpg',
        'display_phone' => '(555) 123-4567',
        'location' => {
          'display_address' => ['123 Test St', 'Test City, CA'],
        },
      },
    ],
  }.to_json.freeze

  setup do
    @user = users(:two)
    @search = searches(:one)
    @coffeeshop = coffeeshops(:one)
    @review = reviews(:one)

    # Mock Yelp API response to prevent real API calls in tests
    RestClient::Request.stubs(:execute).returns(MOCK_API_RESPONSE)
  end

  test '#new' do
    get new_search_url

    assert_response :success

    # Hero heading from the redesigned search page
    assert_select 'h1', text: 'COFFEE NEAR YOU!'

    # Ensure the search form and input are present
    assert_select 'form' do
      assert_select 'input[name=?]', 'search[query]'
    end

    # Geolocation status chip contract for inline location feedback
    assert_select '[data-geolocation-target=?][data-state=?]',
                  'status',
                  'idle',
                  text: 'Checking location...'
  end

  test '#create' do
    assert_difference('Search.count') do
      post searches_path, params: { search: { query: 'tacos', latitude: 0, longitude: 0 } }
    end

    assert_response :found
    assert_equal 'Successfully created search.', flash[:success]
  end

  test '#show' do
    @search.coffeeshops.create!(
      name: 'Linked Phone Cafe',
      address: '456 Link St Test City, CA',
      rating: 4,
      yelp_url: 'https://example.com/linked-phone-cafe',
      image_url: 'https://example.com/linked-phone/o.jpg',
      phone_number: '(415) 555-0123',
    )

    get search_url(@search, locale: nil)

    assert_response :success
    assert_select '.search-results-masthead h2',
                  text: I18n.t('views.searches.results_masthead.heading')
    assert_select '.search-results-masthead__meta-pill',
                  text: /#{Regexp.escape(I18n.t('views.searches.results_masthead.query_label'))}/
    assert_select '[data-testid="results-summary"]', text: /result/

    # Ensure at least one coffeeshop card is rendered when results are present
    assert_select '.coffeeshop-card', minimum: 1
    assert_select '.coffeeshop-card .phone-link[href^="tel:"]', minimum: 1
    assert_select '.coffeeshop-card .phone-link--unavailable', text: 'Phone unavailable', minimum: 1
    assert_select '.coffeeshop-card .phone-link[href="tel:Unknown phone number."]', count: 0
  end

  test '#update' do
    post searches_path, params: { search: { query: 'tacos', latitude: 0, longitude: 0 } }
    @search = Search.last
    patch search_url(@search.id), params: { search: { query: 'yoga', latitude: 0, longitude: 0 } }

    assert_response :found
    assert_equal 'Successfully updated search.', flash[:success]
  end

  test '#update changes query' do
    post searches_path, params: { search: { query: 'yoga', latitude: 0, longitude: 0 } }
    @search = Search.last
    patch search_url(@search.id), params: { search: { query: 'tacos', latitude: 0, longitude: 0 } }
    assert_equal 'tacos', @search.reload.query
  end

end
