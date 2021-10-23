require 'application_system_test_case'

class CoffeeshopsTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test 'A logged in user can favorite, review, edit, delete reviews coffeeshop' do
    visit static_home_url
    fill_in('query', with: '30312')
    click_button('Search')
    click_link('More Info', match: :first)
    assert_current_path %r{^/coffeeshops/\d{9}}
    click_link('Login')
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_button 'Log In'
    assert_current_path %r{^/coffeeshops/\d{9}}
    fill_in('review[content]', with: 'this place is great')
    click_button('Submit Review')
    assert_text('this place is great')
    click_link('Edit this Review')
    assert_current_path %r{^/users/\d{9}/reviews/\d{9}/edit}
    find('#review_rating').find(:xpath, 'option[4]').select_option
    fill_in('review[content]', with: 'this place is bad')
    click_button('Submit Review')
    assert_text('this place is bad')
    assert_selector('#review_rating', text: '★★★★☆')
    assert_current_path %r{^/coffeeshops/\d{9}}
    click_button('Add to my favorites.')
    assert_current_path %r{^/users/\d{9}}
    click_link('More Info', match: :first)
    assert_current_path %r{^/coffeeshops/\d{9}}
    click_button('Remove from my favorites.')
    assert_current_path %r{^/users/\d{9}}
    assert_text("You don't have any favorite shops yet!")
  end
end
