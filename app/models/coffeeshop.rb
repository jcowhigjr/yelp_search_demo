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
      response = RestClient::Request.execute(
        method: 'GET',
        url: "https://api.yelp.com/v3/businesses/search?term=#{query}&latitude=#{lat}&longitude=#{long}",
        headers: { Authorization: "Bearer #{Rails.application.credentials.yelp[:api_key]}" },
      )
      results = JSON.parse(response)
    rescue RestClient::Exception => e
      return "error #{e.inspect}"
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
end
