module OutcomeSignals
  class Summary
    def lines
      [
        'Outcome Signals Summary',
        "Search success events: #{search_successes}",
        "Favorite added events: #{favorites}",
        "Review left events: #{reviews}",
        "Search error events: #{search_errors}",
        "Search-to-favorite rate: #{percentage(favorites, search_successes)}",
        "Search error rate: #{percentage(search_errors, total_search_attempts)}",
        "Average review rating: #{average(ratings)}",
      ]
    end

    private

    def counts
      @counts ||= OutcomeEvent.group(:event_type).count
    end

    def search_successes = counts.fetch('search_success', 0)

    def favorites = counts.fetch('favorite_added', 0)

    def reviews = counts.fetch('review_left', 0)

    def search_errors = counts.fetch('search_error', 0)

    def total_search_attempts = search_successes + search_errors

    def ratings
      @ratings ||= OutcomeEvent.where(event_type: 'review_left').filter_map do |event|
        event.payload['rating']&.to_f
      end
    end

    def percentage(numerator, denominator)
      return 'n/a' if denominator.zero?

      "#{((numerator.to_f / denominator) * 100).round(1)}%"
    end

    def average(values)
      return 'n/a' if values.empty?

      (values.sum / values.size).round(1).to_s
    end
  end
end
