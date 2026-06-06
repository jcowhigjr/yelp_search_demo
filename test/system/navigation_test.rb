require 'application_system_test_case'

class NavigationTest < ApplicationSystemTestCase
  setup do
    stub_yelp_api_request('tacos')
  end

  test 'A user can search and return using the back button' do
    # From the search form
    visit new_search_path
    fill_in 'search[query]', with: 'tacos'

    # Use the first search button to avoid ambiguity
    find('button[aria-label="Search"]').click

    # Wait for results to load and verify we're on the correct page
    wait_for_search_results
    search_id = Search.last.id

    assert_current_path search_path(search_id, locale: nil)
    assert_text 'tacos'

    # Click More Info and verify navigation to a coffeeshop page
    click_more_info_safely

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    # Go back to search results and verify (either show or new)
    go_back

    assert_current_path(%r{^/searches/(new|#{search_id})$}, wait: 10)

    # Go back to search form and verify
    go_back

    assert_current_path new_search_path, wait: 10
  end

  test 'footer renders grouped links and language selection without Materialize nav chrome' do
    visit new_search_path

    within 'footer.page-footer' do
      assert_text 'Jitter'
      assert_selector '.footer-links a.footer-link', text: 'About'
      assert_selector '.footer-links a.footer-link', text: 'Contact'
      assert_selector '.footer-links a.footer-link', text: 'Privacy'
      assert_selector '.footer-language[role="navigation"][aria-label="Language selection"]'
      assert_no_selector 'nav.language-nav'
    end
  end

  private

  def go_back
    if ENV['CUPRITE'] == 'true'
      page.execute_script('window.history.back()')
    else
      page.go_back
    end
  end
end
