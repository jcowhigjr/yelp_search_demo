require "application_system_test_case"

require "minitest/autorun"
require "minitest/focus"
# require "minitest/retry"
# Minitest::Retry.use!

# Minitest::Retry.on_failure do |klass, test_name, result|
#   ENV['SHOW_TESTS'] = 'false'
#   # ENV['CUPRITE'] = 'true'
# end
class BasicsTest < ApplicationSystemTestCase

  test "searching" do
    visit static_home_url
    fill_in('search_query', with: 'tacos')
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

    assert_text "Top Rated Searches for tacos"
  end
end
