# frozen_string_literal: true

module SearchTestHelper
  def wait_for_search_results(timeout: 10)
    # Wait for search results to load — try multiple selectors for resilience
    assert_selector('.search-results, .coffeeshop-card, [data-results], .search-results-grid', wait: timeout)
  end

  def wait_for_more_info_button(timeout: 10)
    # Wait for "More Info" button to be available
    # Try multiple selectors in case the button text is localized differently
    selectors = [
      'a:text("More Info")',
      'a[href*="/coffeeshops/"]',
      '.btn-small',
      'a.btn-small',
      'a.material-button',
    ]
    
    selectors.each do |selector|
      
        find(selector, wait: timeout / selectors.length)
        return true
      rescue Capybara::ElementNotFound
        next
      
    end
    
    false
  end

  def click_more_info_safely
    # Try multiple strategies to click "More Info"
    
      click_on('More Info', match: :first)
    rescue Capybara::ElementNotFound
      # Try alternative selectors
      begin
        first('a[href*="/coffeeshops/"]').click
      rescue Capybara::ElementNotFound
        begin
          first('.material-button').click
        rescue Capybara::ElementNotFound
          first('.btn-small').click
        end
      end
    
  end

  def perform_search(query, from_path: new_search_path)
    visit from_path
    assert_selector 'form.search-bar-container', wait: 10
    fill_in 'search[query]', with: query
    find('button[aria-label="Search"]').click
    
    # Wait for results
    wait_for_search_results
  end
end
