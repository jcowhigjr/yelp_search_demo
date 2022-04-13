class User < ApplicationRecord
  has_secure_password
  validates :name, :email, :password, presence: true
  validates :name, :email, uniqueness: true
  validates :password, :password_confirmation, length: { minimum: 6 }
  has_many :user_favorites
  has_many :coffeeshops, through: :user_favorites
  has_many :reviews
  has_many :searches

  def favorite?(coffeeshop)
    !!user_favorites.find_by(coffeeshop: coffeeshop)
  end
end
