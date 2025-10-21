# frozen_string_literal: true

module SearchTestHelper
  def wait_for_search_results(timeout: 10)
    # Wait for search results to load
    assert_selector('.search-results, .coffeeshop-card, [data-results]', wait: timeout)
  end

  # rubocop:disable Naming/PredicateMethod
  def wait_for_more_info_button(timeout: 10)
    # Wait for "More Info" button to be available
    # Try multiple selectors in case the button text is localized differently
    selectors = [
      'a:text("More Info")',
      'a[href*="/coffeeshops/"]',
      '.btn-small',
      'a.btn-small',
    ]

    selectors.each do |selector|
      if has_selector?(selector, wait: timeout / selectors.length)
        return true
      end
    end

    false
  end
  # rubocop:enable Naming/PredicateMethod

  def click_more_info_safely
    # Try multiple strategies to click "More Info"
    
      click_on('More Info', match: :first)
    rescue Capybara::ElementNotFound
      # Try alternative selectors
      begin
        first('a[href*="/coffeeshops/"]').click
      rescue Capybara::ElementNotFound
        first('.btn-small').click
      end
    
  end

  def perform_search(query, from_path: new_search_path)
    visit from_path
    fill_in 'search[query]', with: query
    click_on 'search'
    
    # Wait for results
    assert_text "Top Rated Searches for #{query} near you", wait: 10
    wait_for_search_results
  end
end
