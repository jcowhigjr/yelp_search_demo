class Coffeeshop < ApplicationRecord
    has_many :reviews
    has_many :users, through: :reviews
    has_many :user_favorites

end
