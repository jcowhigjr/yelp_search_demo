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

    click_on 'search'

    # wait for the results to load
    # wait_for_network_idle! if ENV['CUPRITE'] == 'true'
    page.driver.wait_for_network_idle if ENV['CUPRITE'] == 'true'

    # searches/3 this 3rd seaarch doesn't save when using turbo true on the search button
    assert_current_path search_path(Search.last.id, locale: nil)
    assert_text 'tacos'
    click_on 'More Info', match: :first

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    page.execute_script('window.history.back()')
    page.driver.wait_for_network_idle if ENV['CUPRITE'] == 'true'
# go_back

    # searches/3
    assert_current_path search_path(Search.last.id, locale: nil)

    page.execute_script('window.history.back()')
    page.driver.wait_for_network_idle if ENV['CUPRITE'] == 'true'

    assert_current_path new_search_path
  end
end
