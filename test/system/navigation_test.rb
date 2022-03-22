require 'application_system_test_case'

class NavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
  end

  test 'A user can search and return using the back button' do
    visit new_search_path
    fill_in 'search[query]', with: 'tacos'

    click_button 'Search'

    assert_current_path search_path(Search.last.id)

    click_on 'More Info', match: :first

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    go_back

    assert_current_path search_path(Search.last.id)

    go_back

    assert_current_path new_search_path

  end
end
