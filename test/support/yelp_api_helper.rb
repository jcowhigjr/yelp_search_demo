# test/support/yelp_api_helper.rb
module YelpApiHelper
  # Stubs outbound Yelp business search requests for system and integration tests.
  # Usage:
  #   # Standard happy-path stub with predictable fixture data
  #   stub_yelp_api_request("coffee")
  #
  #   # Override inside a single test to assert error handling flows
  #   stub_request(:get, "https://api.yelp.com/v3/businesses/search")
  #     .to_return(
  #       status: 429,
  #       body: { error: { code: 'RATE_LIMIT', description: 'Too many requests' } }.to_json,
  #       headers: { 'Content-Type' => 'application/json' },
  #     )
  #
  #   # Chain responses to simulate retries or backoff
  #   stub_yelp_api_request("pizza")
  #     .then
  #     .to_return(status: 500, body: { error: 'server_error' }.to_json)
  #     .then
  #     .to_return(status: 200, body: yelp_api_response("pizza"))
  #
  # `search_term` customizes the canned payload returned by +yelp_api_response+.
  # The latitude/longitude arguments are intentionally ignored but kept to mirror
  # call sites that may provide coordinates.
  def stub_yelp_api_request(search_term = nil, _latitude = nil, _longitude = nil)
    # Match any Yelp API search request with query parameters; WebMock asserts
    # that required headers are present to keep the stub close to production.
    stub_request(:get, "https://api.yelp.com/v3/businesses/search")
      .with(
        headers: {
          'Authorization' => /Bearer .*/,
          'Accept' => '*/*',
          'Accept-Encoding' => /gzip/,
          'Host' => 'api.yelp.com',
          'User-Agent' => /rest-client/
        },
        query: hash_including({})
      )
      .to_return(status: 200, body: yelp_api_response(search_term), headers: { 'Content-Type' => 'application/json' })
  end

  private

  # Generates a JSON payload that mirrors the structure returned by the Yelp API.
  # The response swaps the business name based on the provided `search_term`,
  # allowing tests to assert keyword-specific rendering (e.g., Coffee vs Yoga).
  # This helper is intentionally small; tests that need richer payloads can
  # duplicate the shape and tweak fields before passing it to +to_return+.
  def yelp_api_response(search_term)
    # Generate appropriate mock data based on search term
    business_name = case search_term&.downcase
                   when /coffee/
                     'Mock Coffee Shop'
                   when /yoga/
                     'Mock Yoga Studio'
                   when /pizza/
                     'Mock Pizza Place'
                   when /taco/
                     'Mock Taco Shop'
                   else
                     'Mock Business'
                   end
    
    {
      businesses: [
        {
          name: business_name,
          rating: 4.5,
          url: 'https://www.yelp.com/biz/mock-business-seattle',
          image_url: 'https://s3-media3.fl.yelpcdn.com/bphoto/mock.jpg',
          display_phone: '(206) 555-1212',
          location: { display_address: ['123 Mock St', 'Seattle, WA 98101'] },
        },
      ],
    }.to_json
  end
end
