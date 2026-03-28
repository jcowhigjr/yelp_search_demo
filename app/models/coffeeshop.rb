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
    return if results.blank?

    results.each do |data|
      location = data['location']
      next unless location

      address = Array(location['display_address']).join(' ')
      next if address.blank?

      coffeeshop = Coffeeshop.find_or_initialize_by(address: address)
      coffeeshop.assign_attributes(
        name: data['name'].presence || 'No name',
        rating: data['rating']&.clamp(1, 5) || 1,
        yelp_url: data['url'].presence || 'https://yelp.com',
        image_url: data['image_url'].presence || ActionController::Base.helpers.asset_path('tea.png'),
        phone_number: data['display_phone'].presence || 'Unknown phone number.'
      )
      coffeeshop.search = search if coffeeshop.new_record?
      coffeeshop.save
      search.coffeeshops << coffeeshop unless search.coffeeshops.include?(coffeeshop)
    end
  end

  def large_image_url
    image_url.gsub(/o.jpg/, 'l.jpg')
  end
  def google_address_slug
    address.gsub(/[ ,]/, ' ' => '+', ',' => '%2C')
  end
end
