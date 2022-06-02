require 'application_system_test_case'

class NavigationTest < ApplicationSystemTestCase
  setup { @user = users(:two) }

  test 'A user can search and return using the back button' do
    #  searches/new
    visit new_search_path
    fill_in 'search_query', with: 'tacos'

    click_on 'search'
    
    # wait for the results to load
    wait_for_network_idle! if ENV['CUPRITE']

    # searches/3 this 3rd seaarch doesn't save when using turbo true on the search button
    assert_current_path search_path(Search.last.id)
    assert_text 'tacos'
    click_on 'More Info', match: :first

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    go_back

    # searches/3
    assert_current_path search_path(Search.last.id)

    go_back

    assert_current_path new_search_path
  end
end
