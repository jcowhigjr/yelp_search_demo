require 'application_system_test_case'

class NavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
  end

  test 'A user can search and return using the back button' do
    visit new_search_path
    fill_in 'search[query]', with: 'tacos'

    click_button 'Search'

    assert_current_path search_path(Search.last)

    go_back

    assert_current_path new_search_path

  end
end
