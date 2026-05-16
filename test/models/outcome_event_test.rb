require 'test_helper'

class OutcomeEventTest < ActiveSupport::TestCase
  test 'is valid with an allowed event type and payload' do
    event = OutcomeEvent.new(
      user: users(:one),
      event_type: 'search_success',
      payload: { query: 'coffee', result_count: 2 },
    )

    assert_predicate event, :valid?
  end

  test 'rejects unknown event types' do
    event = OutcomeEvent.new(event_type: 'unknown_signal')

    assert_not event.valid?
    assert_includes event.errors[:event_type], 'is not included in the list'
  end
end
