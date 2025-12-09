require 'test_helper'

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @search = searches(:one)
    @coffeeshop = coffeeshops(:one)
    @review = reviews(:one)
    
    # Mock Yelp API response to prevent real API calls in tests
    mock_api_response = {
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
    }.to_json
    
    RestClient::Request.stubs(:execute).returns(mock_api_response)
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
  end

  test '#create' do
    assert_difference('Search.count') do
      post searches_path, params: { search: { query: 'tacos', latitude: 0, longitude: 0 } }
    end

    assert_response :found
    assert_equal 'Successfully created search.', flash[:success]
  end

  test '#show' do
    get search_url(@search, locale: nil)

    assert_response :success
    assert_select 'h2',
                  text: "Top Rated Searches for #{@search.query} near you!",
                  match: :second

    # Ensure at least one coffeeshop card is rendered when results are present
    assert_select '.coffeeshop-card', minimum: 1
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

  test '#update handles API errors by redirecting with a flash message' do
    post searches_path, params: { search: { query: 'yoga', latitude: 0, longitude: 0 } }
    @search = Search.last

    error_message = 'error: Yelp API key not configured. Please set a valid YELP_API_KEY environment variable.'

    Coffeeshop.stubs(:get_search_results).returns(error_message)

    patch search_url(@search.id), params: { search: { query: 'tacos', latitude: 0, longitude: 0 } }

    assert_redirected_to static_home_url
    assert_equal error_message, flash[:error]
  end

end
