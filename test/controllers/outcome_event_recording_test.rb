require 'test_helper'

class OutcomeEventRecordingTest < ActionDispatch::IntegrationTest
  MOCK_API_RESPONSE = {
    'businesses' => [
      {
        'name' => 'Test Coffee Shop',
        'rating' => 4.5,
        'url' => 'https://yelp.com/test',
        'image_url' => 'https://example.com/image.jpg',
        'display_phone' => '(555) 123-4567',
        'location' => { 'display_address' => ['123 Test St', 'Test City, CA'] },
      },
    ],
  }.to_json.freeze

  setup do
    @user = users(:two)
    @coffeeshop = coffeeshops(:one)
    RestClient::Request.stubs(:execute).returns(MOCK_API_RESPONSE)
    login_as(@user)
  end

  test 'search success is recorded' do
    assert_difference('OutcomeEvent.where(event_type: "search_success").count') do
      post searches_path, params: { search: { query: 'espresso', latitude: 0, longitude: 0 } }
    end

    event = OutcomeEvent.order(:created_at).last

    assert_equal @user, event.user
    assert_equal 'espresso', event.payload['query']
    assert_equal Search.last.id, event.payload['search_id']
    assert_equal 1, event.payload['result_count']
  end

  test 'search error is recorded' do
    Coffeeshop.stubs(:get_search_results).returns('error: Yelp API key not configured.')

    assert_difference('OutcomeEvent.where(event_type: "search_error").count') do
      post searches_path, params: { search: { query: 'matcha', latitude: 0, longitude: 0 } }
    end

    event = OutcomeEvent.order(:created_at).last

    assert_equal @user, event.user
    assert_equal 'matcha', event.payload['query']
    assert_equal 'yelp_error', event.payload['error_category']
  end

  test 'return visit is recorded for signed in users with prior searches' do
    @user.searches.create!(query: 'latte', latitude: 0, longitude: 0)

    assert_difference('OutcomeEvent.where(event_type: "return_visit").count') do
      get new_search_url
    end

    event = OutcomeEvent.order(:created_at).last

    assert_equal @user, event.user
    assert_equal 1, event.payload['prior_search_count']
  end

  test 'return visit is recorded only once per session' do
    @user.searches.create!(query: 'latte', latitude: 0, longitude: 0)

    assert_difference('OutcomeEvent.where(event_type: "return_visit").count', 1) do
      get new_search_url
      get new_search_url
    end
  end

  test 'favorite added is recorded' do
    @user.user_favorites.where(coffeeshop: @coffeeshop).destroy_all

    assert_difference('OutcomeEvent.where(event_type: "favorite_added").count') do
      post favorites_path(id: @coffeeshop.id), as: :turbo_stream
    end

    event = OutcomeEvent.order(:created_at).last

    assert_equal @user, event.user
    assert_equal @coffeeshop.id, event.payload['coffeeshop_id']
  end

  test 'review left is recorded' do
    assert_difference('OutcomeEvent.where(event_type: "review_left").count') do
      post coffeeshop_reviews_path(@coffeeshop, locale: nil),
           params: {
             review: {
               user_id: @user.id,
               rating: 5,
               content: 'Excellent espresso',
             },
           }
    end

    event = OutcomeEvent.order(:created_at).last

    assert_equal @user, event.user
    assert_equal @coffeeshop.id, event.payload['coffeeshop_id']
    assert_equal Review.last.id, event.payload['review_id']
    assert_equal 5, event.payload['rating']
  end

  test 'review left is attributed to the current user instead of request params' do
    other_user = users(:one)

    post coffeeshop_reviews_path(@coffeeshop, locale: nil),
         params: {
           review: {
             user_id: other_user.id,
             rating: 5,
             content: 'Excellent espresso',
           },
         }

    event = OutcomeEvent.order(:created_at).last

    assert_equal @user, Review.last.user
    assert_equal @user, event.user
  end

  private

  def login_as(user)
    ApplicationController.any_instance.stubs(:current_user).returns(user)
    ApplicationController.any_instance.stubs(:logged_in?).returns(true)
  end
end
