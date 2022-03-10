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
  test "getting started" do
    visit static_home_url
    assert_text "Save time by sharing your device location"
  end

  test "searching" do
    visit static_home_url
    fill_in('query', with: 'tacos')

  if ENV['SHOW_TESTS']
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
