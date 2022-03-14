require 'application_system_test_case'

class NavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
  end

  test 'A user can search and return using the back button' do
    visit static_home_url
    fill_in('query', with: 'tacos')

    if ENV['SHOW_TESTS'] && !ENV['CUPRITE']
      # sleeping for a second to allow the geolocation api call to complete
      sleep 3
      # need to stub the geolocation api call default is 0.0
      assert_no_selector(:field, 'latitude', type: 'hidden', with: '0.0')
      assert_no_selector(:field, 'longitude', type: 'hidden', with: '0.0')

    else
      # use default geolocation values
      assert_selector(:field, 'latitude', type: 'hidden', with: '0.0')
      assert_selector(:field, 'longitude', type: 'hidden', with: '0.0')
    end

    click_button 'Search'

    assert_current_path searches_path

    go_back

    assert_current_path static_home_path
  end
end
