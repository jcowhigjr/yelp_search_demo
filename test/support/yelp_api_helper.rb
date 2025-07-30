# test/support/yelp_api_helper.rb
module YelpApiHelper
  def stub_yelp_api_request(search_term = nil, _latitude = nil, _longitude = nil)
    # Match any Yelp API search request
    stub_request(:get, %r{https://api\.yelp\.com/v3/businesses/search})
      .with(
        headers: {
          'Authorization' => /Bearer .*/,
        },
      )
      .to_return(status: 200, body: yelp_api_response(search_term), headers: {})
  end

  private

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