class User < ApplicationRecord
  has_secure_password
  validates :name, :email, :password, presence: true
  validates :name, :email, uniqueness: true
  validates :password, :password_confirmation, length: { minimum: 16 }
  has_many :user_favorites, dependent: :destroy
  has_many :coffeeshops, through: :user_favorites
  has_many :reviews, dependent: :destroy
  has_many :searches, dependent: :destroy

  def favorite?(coffeeshop)
    !!user_favorites.find_by(coffeeshop:)
  end
end
