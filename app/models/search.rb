class Search < ApplicationRecord
    belongs_to :user, optional: true
    has_many :coffeeshops
end
