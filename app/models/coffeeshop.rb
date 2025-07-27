class Coffeeshop < ApplicationRecord
  validates :name, :address, :rating, :yelp_url, :phone_number, presence: true
  validates :rating, inclusion: { in: (1..5) }
  has_many :reviews, dependent: :destroy
  has_many :users, through: :reviews
  has_many :user_favorites, dependent: :destroy
  belongs_to :search

  # broadcasts_to ->(coffeeshop) { [coffeeshop.search, :coffeeshops] },
  #               target: ->(coffeeshop) { "search_#{coffeeshop.search_id}_coffeeshops" }

  def self.get_search_results(search)
    # Check if we should use local data instead of API calls
    if Rails.application.config.respond_to?(:use_local_data) && Rails.application.config.use_local_data
      Rails.logger.info "Using local data for search: #{search.query}"
      return use_local_search_data(search)
    end

    # Sanitize and normalize cache key components
    safe_query = search.query.to_s.gsub(/\s+/, '_').downcase
    cache_key = "yelp_search/#{safe_query}/#{search.latitude.to_f.round(4)}/#{search.longitude.to_f.round(4)}"

    # Use caching for Yelp API requests
    coffeeshops = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      query = search.query
      lat = search.latitude
      long = search.longitude
      begin
        response = RestClient::Request.execute(
          method: 'GET',
          url: "https://api.yelp.com/v3/businesses/search?term=#{query}&latitude=#{lat}&longitude=#{long}",
          headers: { Authorization: "Bearer #{Rails.application.credentials.yelp[:api_key]}" },
        )
        results = JSON.parse(response)
        results['businesses']
      rescue RestClient::Exception => e
        Rails.logger.error "Yelp API Error: #{e.inspect}"
        [] # Return an empty array on error
      end
    end

    create_coffee_shops_from_results(coffeeshops, search)
  end

  def self.use_local_search_data(search)
    # First, try to return existing coffeeshops associated with this search
    return search.coffeeshops if search.coffeeshops.any?

    # If no existing coffeeshops, create some mock data based on the search query
    create_mock_coffeeshops_for_search(search)
  end

  def self.create_mock_coffeeshops_for_search(search)
    mock_data = generate_mock_business_data(search.query)
    create_coffee_shops_from_results(mock_data, search)
  end

  def self.generate_mock_business_data(query)
    # Generate mock business data based on search term with appropriate images
    business_info = case query&.downcase
                   when /coffee/
                     { name: 'Local Coffee House', category: 'Coffee', street_num: '100', image: '/assets/sample_coffeeshop_1.svg' }
                   when /yoga/
                     { name: 'Zen Yoga Studio', category: 'Yoga', street_num: '200', image: '/assets/sample_coffee_generic.svg' }
                   when /pizza/
                     { name: 'Tony\'s Pizza Place', category: 'Pizza', street_num: '300', image: '/assets/sample_coffee_generic.svg' }
                   when /taco/
                     { name: 'El Taco Loco', category: 'Taco', street_num: '400', image: '/assets/sample_taco_shop.svg' }
                   else
                     { name: "#{query.titleize} Shop", category: query.titleize, street_num: '500', image: '/assets/sample_coffee_generic.svg' }
                   end

    [
      {
        'name' => business_info[:name],
        'rating' => 4.5,
        'url' => 'https://www.yelp.com/biz/mock-business-local',
        'image_url' => business_info[:image],
        'display_phone' => '(*************',
        'location' => { 'display_address' => ["#{business_info[:street_num]} Main St", 'Local City, ST 12345'] },
      },
      {
        'name' => "Premium #{business_info[:category]}",
        'rating' => 4.0,
        'url' => 'https://www.yelp.com/biz/premium-business-local',
        'image_url' => business_info[:image],
        'display_phone' => '(*************',
        'location' => { 'display_address' => ["#{business_info[:street_num].to_i + 50} Oak Ave", 
'Local City, ST 12345'] },
      },
    ]
  end

  def self.create_coffee_shops_from_results(results, search)
    results.each do |data|
      address = data['location']['display_address'].join(' ')
      search.coffeeshops << Coffeeshop.where(address:).first_or_create do |c|
        c.name = data['name'].empty? ? 'No name' : data['name']
        c.rating = data['rating'] || 0
        c.yelp_url = data['url'].empty? ? 'https://yelp.com' : data['url']
        c.image_url = (data['image_url'].presence || '')
        c.phone_number = data['display_phone'].empty? ? 'Unknown phone number.' : data['display_phone']
      end
    end
  end

  def large_image_url
    return '' if image_url.blank?
    image_url.gsub(/o.jpg/, 'l.jpg')
  end
  def google_address_slug
    address.gsub(/[ ,]/, ' ' => '+', ',' => '%2C')
  end
end
