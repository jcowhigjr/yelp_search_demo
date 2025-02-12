require 'application_system_test_case'

class NavigationTest < ApplicationSystemTestCase
  # setup {  }
  setup do
    @user = users(:two)
    page.driver.browser.command('Browser.grantPermissions',
                                origin: 'http://127.0.0.1',
                                permissions: ['geolocation'],
    )

    # page.driver.browser.command('Emulation.setGeolocationOverride',
    #                             latitude: 0.0,
    #                             longitude: 0.0,
    #                             accuracy: 100,
    # )
  end
  test 'A user can search and return using the back button' do
    #  searches/new
    visit new_search_path
    fill_in 'search_query', with: 'tacos'

    # Use the first search button to avoid ambiguity
    first('button[type="submit"]').click

    # Wait for results to load and verify we're on the correct page
    sleep 2 if ENV['CUPRITE'] == 'true'
    search_id = Search.last.id

    assert_current_path search_path(search_id, locale: nil)
    assert_text 'tacos'

    # Click More Info and verify navigation
    click_on 'More Info', match: :first

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    # Go back to search results and verify
    go_back
    sleep 2 if ENV['CUPRITE'] == 'true'

    assert_current_path search_path(search_id, locale: nil)

    # Go back to search form and verify
    go_back
    sleep 2 if ENV['CUPRITE'] == 'true'

    assert_current_path new_search_path
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
