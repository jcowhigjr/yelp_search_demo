class Search < ApplicationRecord
  belongs_to :user, optional: true
  has_many :coffeeshops, -> { order rating: :desc }

  attribute :latitude, :float, default: 0.0
  attribute :longitude, :float, default: 0.0

  validates :query, presence: true
  validates :latitude, presence: true, numericality: { in: -90..90 }
  validates :longitude, presence: true, numericality: { in: -180..180 }

  # broadcasts target: :coffeeshops, action: :create, channel: -> { "search_#{id}" }

end
