module OutcomeEvents
  module_function

  def record(event_type, user: nil, payload: {})
    ActiveSupport::Notifications.instrument(
      'outcome_event.yelp_search_demo',
      event_type:,
      user_id: user&.id,
      payload:,
    )

    OutcomeEvent.create!(event_type:, user:, payload:)
  end
end
