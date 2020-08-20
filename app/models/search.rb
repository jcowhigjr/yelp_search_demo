class Search < ApplicationRecord
    belongs_to :user
    has_many :coffeeshops, dependent: :delete_all
end
