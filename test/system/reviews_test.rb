require 'application_system_test_case'

require 'minitest/autorun'
require 'minitest/focus'

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
    visit coffeeshop_path(@coffeeshop, locale: nil)
    fill_in 'Please give a brief description of your experience at Coffeeshop 1.',
            with: 'the cafe mocha is my fav'
    click_on 'SUBMIT REVIEW'

    assert_text('the cafe mocha is my fav')
  end

end
