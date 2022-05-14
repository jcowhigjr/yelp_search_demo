require 'application_system_test_case'

require 'minitest/autorun'
require 'minitest/focus'
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

  test 'Adding a review' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'menu'
    click_on 'My Profile'
    visit '/coffeeshops/1'
    fill_in 'Please give a brief description of your experience at Coffeeshop 1.',
            with: 'the cafe mocha is my fav'
    click_on 'Submit Review'
    assert_text('the cafe mocha is my fav')
  end

  test 'BUG: Adding a review breaks side menu' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'
    click_on 'menu'
    click_on 'My Profile'
    visit '/coffeeshops/1'
    fill_in 'Please give a brief description of your experience at Coffeeshop 1.',
            with: 'the cafe mocha is my fav'
    #
    # skip 'create a javascript test to check that the side menu is still there'
    click_on 'Submit Review'
    # # VM865:1 Uncaught SyntaxError: Identifier 'slide_menu' has already been declared
    # at oe.assignNewBody (turbo.es2017-esm.js:2407:27)
    # at turbo.es2017-esm.js:2369:18
    # at Function.preservingPermanentElements (turbo.es2017-esm.js:961:9)
    # at oe.preservingPermanentElements (turbo.es2017-esm.js:1039:15)
    # at oe.replaceBody (turbo.es2017-esm.js:2367:14)
    # at oe.render (turbo.es2017-esm.js:2342:18)
    # at ce.renderSnapshot (turbo.es2017-esm.js:892:24)
    # at ce.render (turbo.es2017-esm.js:862:28)
    # at ce.renderPage (turbo.es2017-esm.js:2483:21)
    # at turbo.es2017-esm.js:1517:37
    assert_text('the cafe mocha is my fav')
  end
end
