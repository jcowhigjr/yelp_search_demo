require 'test_helper'
require 'rake'

class OutcomeSignalsTaskTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks
    Rake::Task['outcome_signals:summary'].reenable
  end

  test 'summary prints zero counts and unavailable rates without events' do
    OutcomeEvent.delete_all

    output, = capture_io do
      Rake::Task['outcome_signals:summary'].invoke
    end

    assert_includes output, 'Outcome Signals Summary'
    assert_includes output, 'Search success events: 0'
    assert_includes output, 'Search-to-favorite rate: n/a'
    assert_includes output, 'Search error rate: n/a'
    assert_includes output, 'Average review rating: n/a'
  end

  test 'summary prints search, favorite, review, and error metrics' do
    OutcomeEvent.delete_all
    OutcomeEvent.create!(event_type: 'search_success', payload: { query: 'coffee' })
    OutcomeEvent.create!(event_type: 'search_success', payload: { query: 'latte' })
    OutcomeEvent.create!(event_type: 'favorite_added', payload: { coffeeshop_id: coffeeshops(:one).id })
    OutcomeEvent.create!(event_type: 'review_left', payload: { rating: 4 })
    OutcomeEvent.create!(event_type: 'review_left', payload: { rating: 5 })
    OutcomeEvent.create!(event_type: 'search_error', payload: { error_category: 'yelp_error' })

    output, = capture_io do
      Rake::Task['outcome_signals:summary'].invoke
    end

    assert_includes output, 'Search success events: 2'
    assert_includes output, 'Favorite added events: 1'
    assert_includes output, 'Review left events: 2'
    assert_includes output, 'Search error events: 1'
    assert_includes output, 'Search-to-favorite rate: 50.0%'
    assert_includes output, 'Search error rate: 33.3%'
    assert_includes output, 'Average review rating: 4.5'
  end
end
