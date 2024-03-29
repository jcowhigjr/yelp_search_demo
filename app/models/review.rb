class Review < ApplicationRecord
  validates :content, :rating, presence: true
  validates :rating, inclusion: { in: 1..5 }
  belongs_to :user
  belongs_to :coffeeshop
  scope :order_reviews,
        ->(user_id) { where('user_id == ?', user_id).order('rating desc') }

  # after_create_commit { broadcast_prepend_to 'reviews' }
  # after_update_commit { broadcast_replace_to 'reviews' }
  # after_destroy_commit { broadcast_remove_to 'reviews' }

  def rating_in_stars
    case rating
    when 1
      '★☆☆☆☆'
    when 2
      '★★☆☆☆'
    when 3
      '★★★☆☆'
    when 4
      '★★★★☆'
    when 5
      '★★★★★'
    end
  end
end
