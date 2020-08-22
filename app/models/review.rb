class Review < ApplicationRecord
    belongs_to :user
    belongs_to :coffeeshop

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
