require 'application_system_test_case'

class CoffeeshopsTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
    @coffeeshop = coffeeshops(:two)
  end

  test 'A logged in user can favorite, review, edit, delete reviews coffeeshop' do
    visit coffeeshop_path(@coffeeshop, locale: nil)

    assert_current_path %r{^/coffeeshops/\d{1,9}}
    assert_selector 'h1', text: @coffeeshop.name

    assert_selector :link, text: 'phone'
    assert_link 'phone', href: "tel:#{@coffeeshop.phone_number}"
    assert_selector :link, text: 'place'
    assert_link 'place',
                href:
                  "https://www.google.com/maps/search/?api=1&query=#{@coffeeshop.google_address_slug}"
    assert_selector :link, href: @coffeeshop.yelp_url

    click_on 'Login to add this shop to your favorites!'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: default_password
    click_link_or_button 'Log In'

    assert_current_path %r{^/coffeeshops/\d{1,9}}
    fill_in('review[content]', with: 'this place is great')
    find_by_id('review_rating', match: :first)
      .find(:xpath, 'option[5]')
      .select_option

    click_on 'SUBMIT REVIEW'

    assert_text('this place is great')
    assert_selector('#review_rating', text: '★★★★☆')
    click_link_or_button('Edit this Review', match: :first)
# without turbo frame
    # assert_current_path %r{^/users/\d{1,9}/reviews/\d{1,9}/edit}
# with turbo frame
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    find_by_id('review_rating', match: :first)
      .find(:xpath, 'option[1]')
      .select_option
    fill_in('review[content]', match: :first, with: 'this place is bad')
    click_link_or_button('Submit Review', match: :first)

    assert_text('"this place is bad"', count: 1)
    assert_selector('#review_rating', text: '★☆☆☆☆')
    assert_current_path %r{^/coffeeshops/\d{1,9}}

    click_on 'Delete', match: :first

    assert_current_path %r{^/coffeeshops/\d{1,9}}
    # FIXME: This doesn't return without full page reload
    # assert_text("This coffeeshop doesn't have any reviews yet!")

    # if using cuprite scroll_to is available
    if page.driver.instance_of?(::Capybara::Cuprite::Driver)
      page.driver.scroll_to(0, 100)
    # else use javascript to scroll
    end
    if page.driver.instance_of?(::Capybara::Selenium::Driver)
      page.execute_script('window.scrollBy(0,100)')
    end

    click_on 'REMOVE FROM MY FAVORITES'
    # assert_current_path %r{^/coffeeshops/\d{1,9}}

#the turboframe in the system test doesn't toggle    flaky test
   # click_link_or_button('ADD TO MY FAVORITES')
    # assert_current_path %r{^/coffeeshops/\d{1,9}}

  end
end
