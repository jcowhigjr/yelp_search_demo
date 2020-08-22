class User < ApplicationRecord
    has_secure_password
    validates :name, :email, :password, presence: true;
    validates :name, :email, uniqueness: true
    validates :password, length: {in: 6..20}
    has_many :user_favorites
    has_many :coffeeshops, through: :user_favorites
    has_many :reviews
    has_many :searches

    def favorite?(coffeeshop)
        !!self.user_favorites.where(coffeeshop: coffeeshop)
    end
    
end
