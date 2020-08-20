class Search < ApplicationRecord
    belongs_to :user, optional: true
    has_many :coffeeshops, dependent: :delete_all
end
