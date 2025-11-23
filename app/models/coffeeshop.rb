class Coffeeshop < ApplicationRecord
  validates :name, :address, :rating, :yelp_url, :image_url, :phone_number, presence: true
  validates :rating, inclusion: { in: (1..5) }
  has_many :reviews, dependent: :destroy
  has_many :users, through: :reviews
  has_many :user_favorites, dependent: :destroy
  belongs_to :search

  # broadcasts_to ->(coffeeshop) { [coffeeshop.search, :coffeeshops] },
  #               target: ->(coffeeshop) { "search_#{coffeeshop.search_id}_coffeeshops" }

  def self.get_search_results(search)
    query = search.query
    lat = search.latitude
    long = search.longitude
    begin
      # Try to get API key from credentials, fallback to environment variable
      api_key = Rails.application.credentials.dig(:yelp, :api_key) || ENV.fetch('YELP_API_KEY', nil)
      
      if api_key.blank? || api_key == 'REPLACE_WITH_YOUR_YELP_API_KEY'
        return create_coffee_shops_from_results(test_fallback_results, search) if Rails.env.test?
        return "error: Yelp API key not configured. Please set a valid YELP_API_KEY environment variable. Get your API key from: https://www.yelp.com/developers/v3/manage_app"
      end
      
      response = RestClient::Request.execute(
        method: 'GET',
        url: "https://api.yelp.com/v3/businesses/search?term=#{query}&latitude=#{lat}&longitude=#{long}",
        headers: { Authorization: "Bearer #{api_key}" },
      )
      results = JSON.parse(response)
    rescue RestClient::Exception => e
      # Log the detailed error for debugging but return a generic message to users
      Rails.logger.error("Yelp API request failed: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n")) if e.backtrace
      return "error: Unable to connect to Yelp. Please try again later."
    end

    coffeeshops = results['businesses']
    create_coffee_shops_from_results(coffeeshops, search)
  end

  def self.create_coffee_shops_from_results(results, search)
    results.each do |data|
      address = data['location']['display_address'].join(' ')
      search.coffeeshops << Coffeeshop.where(address:).first_or_create do |c|
        c.name = data['name'].empty? ? 'No name' : data['name']
        c.rating = data['rating'] || 0
        c.yelp_url = data['url'].empty? ? 'https://yelp.com' : data['url']
        c.image_url = data['image_url'].empty? ? '/public/images/tea.png' : data['image_url']
        c.phone_number = data['display_phone'].empty? ? 'Unknown phone number.' : data['display_phone']
      end
    end
  end

  def large_image_url
    image_url.gsub(/o.jpg/, 'l.jpg')
  end
  def google_address_slug
    address.gsub(/[ ,]/, ' ' => '+', ',' => '%2C')
  end

  def self.test_fallback_results
    [{
      'name' => 'Test Coffee Shop',
      'rating' => 4.0,
      'url' => 'https://example.com/coffee',
      'image_url' => 'https://example.com/image.jpg',
      'display_phone' => '(555) 000-0000',
      'location' => { 'display_address' => ['123 Test St', 'Test City, CA'] },
    }]
  end
end
