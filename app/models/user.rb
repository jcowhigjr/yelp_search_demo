class User < ApplicationRecord
    has_secure_password
    has_many :user_favorites
    has_many :favorite_coffeeshops, through: :user_favorites, source: :coffeshop
    has_many :reviews
    has_many :searches
end
