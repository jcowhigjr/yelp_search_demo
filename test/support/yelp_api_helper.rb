# test/support/yelp_api_helper.rb
module YelpApiHelper
  def stub_yelp_api_request(search_term, latitude, longitude, scenario: :success)
    # Match the exact URL format used in the model
    stub_request(:get, /https:\/\/api\.yelp\.com\/v3\/businesses\/search\?.*term=.*/)  
      .with(
        headers: {
          'Authorization' => /Bearer .*/
        }
      )
      .to_return(yelp_api_response_for_scenario(scenario, search_term))
  end

  def stub_yelp_api_success(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
    stub_yelp_api_request(search_term, latitude, longitude, scenario: :success)
  end

  def stub_yelp_api_error(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
    stub_yelp_api_request(search_term, latitude, longitude, scenario: :error)
  end

  def stub_yelp_api_empty(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
    stub_yelp_api_request(search_term, latitude, longitude, scenario: :empty)
  end

  def stub_yelp_api_rate_limited(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
    stub_yelp_api_request(search_term, latitude, longitude, scenario: :rate_limited)
  end

  def stub_yelp_api_multiple_results(search_term = 'coffee', latitude = 40.748817, longitude = -73.985428)
    stub_yelp_api_request(search_term, latitude, longitude, scenario: :multiple_results)
  end

  def stub_yelp_api_with_custom_data(search_term, latitude, longitude, custom_response)
    stub_request(:get, /https:\/\/api\.yelp\.com\/v3\/businesses\/search\?.*term=.*/)  
      .with(
        headers: {
          'Authorization' => /Bearer .*/
        }
      )
      .to_return(status: 200, body: custom_response.to_json, headers: {})
  end

  # Clear all Yelp API stubs - useful for test cleanup
  def clear_yelp_api_stubs
    WebMock.reset!
  end

  private

  def yelp_api_response_for_scenario(scenario, search_term)
    case scenario
    when :success
      { status: 200, body: yelp_api_success_response(search_term), headers: {} }
    when :error
      { status: 500, body: yelp_api_error_response, headers: {} }
    when :empty
      { status: 200, body: yelp_api_empty_response, headers: {} }
    when :rate_limited
      { status: 429, body: yelp_api_rate_limit_response, headers: {} }
    when :multiple_results
      { status: 200, body: yelp_api_multiple_results_response(search_term), headers: {} }
    else
      { status: 200, body: yelp_api_success_response(search_term), headers: {} }
    end
  end

  def yelp_api_success_response(search_term = 'coffee')
    {
      "businesses": [
        {
          "name": "Mock #{search_term.capitalize} Shop",
          "rating": 4.5,
          "url": "https://www.yelp.com/biz/mock-#{search_term.downcase}-shop-seattle",
          "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/mock.jpg",
          "display_phone": "(206) 555-1212",
          "location": { "display_address": ["123 Mock St", "Seattle, WA 98101"] }
        }
      ]
    }.to_json
  end

  def yelp_api_error_response
    {
      "error": {
        "code": "INTERNAL_ERROR",
        "description": "An internal error occurred. Please try again later."
      }
    }.to_json
  end

  def yelp_api_empty_response
    {
      "businesses": [],
      "total": 0
    }.to_json
  end

  def yelp_api_rate_limit_response
    {
      "error": {
        "code": "ACCESS_LIMIT_REACHED",
        "description": "You have exceeded the request limit. Please try again later."
      }
    }.to_json
  end

  def yelp_api_multiple_results_response(search_term = 'coffee')
    {
      "businesses": [
        {
          "name": "Best #{search_term.capitalize} Downtown",
          "rating": 4.8,
          "url": "https://www.yelp.com/biz/best-#{search_term.downcase}-downtown-seattle",
          "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/best1.jpg",
          "display_phone": "(206) 555-0001",
          "location": { "display_address": ["456 Main St", "Seattle, WA 98101"] }
        },
        {
          "name": "Premium #{search_term.capitalize} House",
          "rating": 4.6,
          "url": "https://www.yelp.com/biz/premium-#{search_term.downcase}-house-seattle",
          "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/premium2.jpg",
          "display_phone": "(206) 555-0002",
          "location": { "display_address": ["789 Pike St", "Seattle, WA 98101"] }
        },
        {
          "name": "Local #{search_term.capitalize} Co",
          "rating": 4.3,
          "url": "https://www.yelp.com/biz/local-#{search_term.downcase}-co-seattle",
          "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/local3.jpg",
          "display_phone": "(206) 555-0003",
          "location": { "display_address": ["321 1st Ave", "Seattle, WA 98101"] }
        }
      ],
      "total": 3
    }.to_json
  end
end
