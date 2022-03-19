require 'application_system_test_case'

class CoffeeshopsTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
    @coffeeshop = coffeeshops(:two)
  end
  test 'A logged in user can favorite, review, edit, delete reviews coffeeshop' do

    visit coffeeshop_path(@coffeeshop)
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    assert_selector 'h1', text: @coffeeshop.name
    assert_link @coffeeshop.phone_number
    assert_link @coffeeshop.address
    click_on 'Login to add this shop to your favorites!'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: default_password
    click_button 'Log In'
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    fill_in('review[content]', with: 'this place is great')
    find('#review_rating', match: :first).find(:xpath, 'option[5]').select_option
    click_button('Submit Review')
    assert_text('this place is great')
    assert_selector('#review_rating', text: '★★★★☆')
    click_link('Edit this Review', match: :first)
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    find('#review_rating', match: :first).find(:xpath, 'option[1]').select_option
    fill_in('review[content]', match: :first, with: 'this place is bad')
    click_button('Submit Review', match: :first)
    assert_text('"this place is bad"', count: 1)
    assert_selector('#review_rating', text: '★☆☆☆☆')
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    click_button 'Delete', match: :first
    click_button 'Delete', match: :first
    # FIXME: This doesn't return without full page reload
    # assert_text("This coffeeshop doesn't have any reviews yet!")
    click_button('Remove from my favorites.')
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    click_button('Add to my favorites.')
    assert_current_path %r{^/coffeeshops/\d{1,9}}
  end
end
