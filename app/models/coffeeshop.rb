class Coffeeshop < ApplicationRecord
    validates :name, :address, :rating, :yelp_url, :image_url, :phone_number, presence: true
    scope :ordered_by_rating, -> { order(rating: :desc)}
    has_many :reviews
    has_many :users, through: :reviews
    has_many :user_favorites
    belongs_to :search

    def self.get_search_results(query)
        response = RestClient::Request.execute(
            method: "GET",
            url: "https://api.yelp.com/v3/businesses/search?term=coffee&location=#{query}",
            headers: { Authorization: "Bearer #{ENV['YELP_API_KEY']}"}
        )
        results = JSON.parse(response)
        coffeeshops = results["businesses"]
        create_coffee_shops_from_results(coffeeshops)
    end

    def self.create_coffee_shops_from_results(results)
        results.map do |data|
            Coffeeshop.find_or_create_by(address: data["location"]["display_address"].join(" ")) do |c|
                c.name = data["name"]
                c.rating = data["rating"]
                c.yelp_url = data["url"]
                c.image_url = data["image_url"]
                c.phone_number = data["display_phone"]
            end
        end
    end


end
