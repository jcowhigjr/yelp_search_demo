# frozen_string_literal: true

module SearchTestHelper
  # Waits for actual search result cards to render.
  # Checks for .coffeeshop-card (minimum: 1) rather than container selectors
  # like .search-results or .search-results-grid, which may exist as empty
  # elements before results load.
  def wait_for_search_results(timeout: 10)
    assert_selector('.coffeeshop-card', minimum: 1, wait: timeout)
  end

  def wait_for_more_info_button(timeout: 10)
    selectors = [
      'a:text("More Info")',
      'a[href*="/coffeeshops/"]',
      'a.material-button',
      '.btn-small',
      'a.btn-small',
    ]
    
    selectors.each do |selector|
      
        find(selector, wait: timeout / selectors.length)
        return true
      rescue Capybara::ElementNotFound
        next
      
    end
    
    false
  end

  # Clicks the first "More Info" / coffeeshop link using a fallback chain.
  # Uses find(match: :first) instead of first() so that a miss raises
  # Capybara::ElementNotFound (caught by rescue) rather than returning nil
  # and raising NoMethodError on .click.
  def click_more_info_safely
    click_on('More Info', match: :first)
  rescue Capybara::ElementNotFound
    begin
      find('a[href*="/coffeeshops/"]', match: :first).click
    rescue Capybara::ElementNotFound
      begin
        find('.material-button', match: :first).click
      rescue Capybara::ElementNotFound
        find('.btn-small', match: :first).click
      end
    end
  end

  def perform_search(query, from_path: new_search_path)
    visit from_path
    assert_selector 'form.search-bar-container', wait: 10
    fill_in 'search[query]', with: query
    find('button[aria-label="Search"]').click

    # Wait for actual result cards, not just containers
    wait_for_search_results
  end
end
