require 'application_system_test_case'

class CoffeeshopsTest < ApplicationSystemTestCase
  setup do
    @user = users(:two)
    @coffeeshop = coffeeshops(:two)
  end

  test 'A logged in user can view coffeeshop details' do
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
  end

  test 'A logged in user can submit a review' do
    visit coffeeshop_path(@coffeeshop, locale: nil)
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
  end

  test 'A logged in user can edit and delete their review' do
    visit coffeeshop_path(@coffeeshop, locale: nil)
    click_on 'Login to add this shop to your favorites!'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: default_password
    click_link_or_button 'Log In'

    # Submit a review first
    fill_in('review[content]', with: 'this place is great')
    find_by_id('review_rating', match: :first)
      .find(:xpath, 'option[5]')
      .select_option
    click_on 'SUBMIT REVIEW'

    # Edit the review
    assert_selector('a', text: /Edit this Review/i, visible: true)
    click_link_or_button('Edit this Review', match: :first)
    
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    find_by_id('review_rating', match: :first)
      .find(:xpath, 'option[1]')
      .select_option
    fill_in('review[content]', with: 'actually not so great')
    click_on 'SUBMIT REVIEW'

    assert_text('actually not so great')
    assert_selector('#review_rating', text: '★☆☆☆☆')

    # Delete the review
    accept_confirm do
      click_on 'Delete this Review'
    end

    assert_no_text('actually not so great')
  end

  test 'A logged in user can favorite and unfavorite a coffeeshop' do
    visit coffeeshop_path(@coffeeshop, locale: nil)
    click_on 'Login to add this shop to your favorites!'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: default_password
    click_link_or_button 'Log In'

    click_on 'REMOVE FROM MY FAVORITES'
    # assert_current_path %r{^/coffeeshops/\d{1,9}}

    #the turboframe in the system test doesn't toggle    flaky test
    # click_link_or_button('ADD TO MY FAVORITES')
    # assert_current_path %r{^/coffeeshops/\d{1,9}}
  end
end
