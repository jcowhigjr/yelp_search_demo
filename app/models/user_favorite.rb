class UserFavorite < ApplicationRecord
    validates :user, :coffeeshop, presence: true
    belongs_to :user
    belongs_to :coffeeshop
end
