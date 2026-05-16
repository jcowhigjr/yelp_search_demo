class OutcomeEvent < ApplicationRecord
  EVENT_TYPES = %w[
    search_success
    search_error
    favorite_added
    review_left
    return_visit
  ].freeze

  belongs_to :user, optional: true

  validates :event_type, presence: true, inclusion: { in: EVENT_TYPES }
end
