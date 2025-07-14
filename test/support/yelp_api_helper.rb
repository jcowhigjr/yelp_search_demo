# test/support/yelp_api_helper.rb
module YelpApiHelper
  def stub_yelp_api_request(search_term, latitude, longitude)
    # Match the exact URL format used in the model
    stub_request(:get, /https:\/\/api\.yelp\.com\/v3\/businesses\/search\?.*term=.*/)  
      .with(
        headers: {
          'Authorization' => /Bearer .*/
        }
      )
      .to_return(status: 200, body: yelp_api_response, headers: {})
  end

  private

  def yelp_api_response
    {
      "businesses": [
        {
          "name": "Mock Coffee Shop",
          "rating": 4.5,
          "url": "https://www.yelp.com/biz/mock-coffee-shop-seattle",
          "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/mock.jpg",
          "display_phone": "(206) 555-1212",
          "location": { "display_address": ["123 Mock St", "Seattle, WA 98101"] }
        }
      ]
    }.to_json
  end
end