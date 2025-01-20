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

    # Wait for results to load
    sleep 2 if ENV['CUPRITE'] == 'true'

    # searches/3 this 3rd seaarch doesn't save when using turbo true on the search button
    assert_current_path search_path(Search.last.id, locale: nil)
    assert_text 'tacos'
    click_on 'More Info', match: :first

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    # Go back and wait
    page.execute_script('window.history.back()')
    sleep 2 if ENV['CUPRITE'] == 'true'

    # Check we're back at search results
    assert_current_path search_path(Search.last.id, locale: nil)

    # Go back again and wait
    page.execute_script('window.history.back()')
    sleep 2 if ENV['CUPRITE'] == 'true'

    # Check we're back at search form
    assert_current_path new_search_path
  end
end
