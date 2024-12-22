class Search < ApplicationRecord
  belongs_to :user, optional: true
  has_many :coffeeshops, -> { order rating: :desc }, dependent: :destroy, inverse_of: :search

  attribute :latitude, :float, default: 0.0
  attribute :longitude, :float, default: 0.0

  validates :query, presence: true
  validates :latitude, presence: true, numericality: { in: -90..90 }
  validates :longitude, presence: true, numericality: { in: -180..180 }

  #  this presentation logic should be in the controller

  def picker_choices
    names
  end

  private
    def results
      coffeeshops.order(rating: :desc).limit(10)
    end

    def names
      results.map(&:name)
    end

end
