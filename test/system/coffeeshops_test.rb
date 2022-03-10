require 'application_system_test_case'

class CoffeeshopsTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
  end

  test 'A logged in user can favorite, review, edit, delete reviews coffeeshop' do
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


    click_link('More Info', match: :first)
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    click_on 'Login to add this shop to your favorites!'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: default_password
    click_button 'Log In'
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    fill_in('review[content]', with: 'this place is great')
    click_button('Submit Review')
    assert_text('this place is great')
    click_link('Edit this Review', match: :first)
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    find('#review_rating').find(:xpath, 'option[4]').select_option
    fill_in('review[content]', match: :first, with: 'this place is bad')
    click_button('Submit Review', match: :first)
    assert_text('"this place is bad"', count: 1)
    assert_selector('#review_rating', text: '★★★★☆')
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    click_button 'Delete', match: :first
    # FIXME: This doesn't return without full page reload
    # assert_text("This coffeeshop doesn't have any reviews yet!")
    click_button('Add to my favorites.')
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    click_button('Remove from my favorites.')
    assert_current_path %r{^/coffeeshops/\d{1,9}}
  end
end
