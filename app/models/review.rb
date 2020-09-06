class Review < ApplicationRecord
    validates :content, :rating, :user, :coffeeshop, presence: true
    validates :rating, inclusion: {in: 1..5}
    belongs_to :user
    belongs_to :coffeeshop
    scope :order_reviews, -> (user_id) {where('user_id == ?', user_id).order('rating desc')}


    def rating_in_stars
        case self.rating
        when 1
            "★☆☆☆☆"
        when 2
            "★★☆☆☆"
        when 3
            "★★★☆☆"
        when 4
            "★★★★☆"
        when 5
            "★★★★★"
        end
    end
end
