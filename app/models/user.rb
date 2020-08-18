class User < ApplicationRecord
    has_many :user_favorites
    has_many :coffeeshops, through: :user_favorites
    has_many :reviews
end
