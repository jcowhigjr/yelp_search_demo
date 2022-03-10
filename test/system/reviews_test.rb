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
  setup do
    @user = users(:one)
    @coffeeshop = coffeeshops(:one)
    @review = reviews(:one)
  end
  test "Adding a review" do
    visit '/login'
    fill_in 'email', with: @user.email
    click_on 'Log In'
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'My Profile'
    visit '/coffeeshops/1'
    fill_in 'Please give a brief description of your experience at Coffeeshop 1.', with: 'the cafe mocha is my fav'
    click_on 'Submit Review'
    assert_text('the cafe mocha is my fav')
  end
end
