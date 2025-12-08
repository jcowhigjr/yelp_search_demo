class Restaurant < ApplicationRecord
  validates :name, :address, :rating, :yelp_url, :image_url, :phone_number, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 1.0, less_than_or_equal_to: 5.0 }
end
