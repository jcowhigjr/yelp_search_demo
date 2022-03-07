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
    assert_text "Search by city to find your new favorite coffeeshop"
  end

  test "searching" do
    visit static_home_url
    fill_in('query', with: 'tacos')
    click_button('Search')
    assert_text "Top Rated Coffeeshops in tacos"
  end
end
