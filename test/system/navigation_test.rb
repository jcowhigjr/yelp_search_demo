require 'application_system_test_case'

class NavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
  end

  test 'A user can search and return using the back button' do
    #  searches/new
    visit new_search_path
    fill_in 'search_query', with: 'tacos'

    click_on 'search'

    # searches/3 this 3rd seaarch doesn't save when using turbo true on the search button
    assert_current_path search_path(Search.last.id)

    click_on 'More Info', match: :first

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    go_back

    # searches/3
    assert_current_path search_path(Search.last.id)

    go_back

    assert_current_path new_search_path

  end
end
