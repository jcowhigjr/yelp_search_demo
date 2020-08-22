class Search < ApplicationRecord
    validates :user_id, :query, presence: true
    belongs_to :user, optional: true
    has_many :coffeeshops, -> {order rating: :desc}
    

    # def sort_by_rating
    #    self.coffeeshops.order("coffeeshops.rating DESC")
    # end
end
