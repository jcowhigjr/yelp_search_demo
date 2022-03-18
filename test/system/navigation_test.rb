require 'application_system_test_case'

class NavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
  end

  test 'A user can search and return using the back button' do
    visit new_search_path
    fill_in 'search[query]', with: 'tacos'

    coffeeshop_count = Coffeeshop.count

    search_count = Search.count

    click_button 'Search'

    assert_current_path search_path(search_count)

    click_on 'More Info', match: :first

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    go_back

    assert_current_path search_path(coffeeshop_count)

    go_back

    assert_current_path new_search_path

    go_back

    assert_current_path  static_home_path

  end
end
