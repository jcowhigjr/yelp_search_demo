class Search < ApplicationRecord
  belongs_to :user, optional: true
  has_many :coffeeshops, -> { order rating: :desc }

  # broadcasts target: :coffeeshops, action: :create, channel: -> { "search_#{id}" }

end
