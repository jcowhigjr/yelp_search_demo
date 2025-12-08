class Restaurant < ApplicationRecord
  validates :rating, numericality: { greater_than_or_equal_to: 1.0, less_than_or_equal_to: 5.0 }, allow_nil: true
end
