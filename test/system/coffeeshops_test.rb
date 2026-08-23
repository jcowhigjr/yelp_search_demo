require 'application_system_test_case'

class CoffeeshopsTest < ApplicationSystemTestCase
  include ActionView::Helpers::NumberHelper
  include DetailFavoriteHelper

  setup do
    stub_yelp_api_request('coffee')
    @user = users(:two)
    @coffeeshop = coffeeshops(:two)
    @review = reviews(:two)
  end

  test 'An unauthenticated user can view coffeeshop details' do
    visit coffeeshop_path(@coffeeshop, locale: nil)

    assert_current_path %r{^/coffeeshops/\d{1,9}}
    assert_selector 'h1', text: @coffeeshop.name

    assert_selector 'a', text: '← BACK TO RESULTS'

    within('[data-testid="about-section"]') do
      assert_link @coffeeshop.address,
                  href:
                    "https://www.google.com/maps/search/?api=1&query=#{@coffeeshop.google_address_slug}"
      assert_link number_to_phone(@coffeeshop.phone_number, area_code: true),
                  href: "tel:#{number_to_phone(@coffeeshop.phone_number, area_code: true)}"
      assert_link 'View on Yelp', href: @coffeeshop.yelp_url

      assert_selector 'svg.fa-yelp.yelp_color'
    end

    assert_selector 'a', text: 'GET DIRECTIONS'
    assert_selector 'a', text: 'CALL NOW'
    assert_text "(#{@coffeeshop.reviews.size} #{'review'.pluralize(@coffeeshop.reviews.size)})"
    assert_selector 'i.material-icons[aria-label="Not favorited"]', text: 'favorite_border'
    assert_selector '.review-container', minimum: 1, wait: 5
  end

  test 'A logged in user can submit a review' do
    visit '/login'

    assert_selector 'h1', text: 'Login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    assert_current_path '/sessions'

    visit new_search_path

    assert_selector 'form.search-bar-container'
    fill_in 'search[query]', with: 'coffee'

    assert_selector(:field, 'search[query]', with: 'coffee')
    first('button[type="submit"]').click

    assert_current_path search_path(Search.last.id, locale: nil)
    wait_for_search_results
    click_more_info_safely

    toggle_detail_favorite('Add to favorites', 'Remove from favorites')

    select '★★★★★', from: 'review[rating]'
    fill_in 'review[content]', match: :first, with: 'Great coffee!'

    click_on 'SUBMIT REVIEW'

    assert_text 'Great coffee!'
  end

  test 'A logged in user can edit and delete their review' do
    visit '/login'

    assert_selector 'h1', text: 'Login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    assert_current_path '/sessions'

    visit coffeeshop_path(@coffeeshop, locale: nil)

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    within('.review-container', text: 'Cold Brew is the best') do
      click_on 'Edit this Review'

      assert_selector('form')
      fill_in 'review[content]', with: 'Amazing coffee!'
      click_on 'SUBMIT REVIEW'
    end

    assert_current_path %r{^/coffeeshops/\d{1,9}}
    assert_text 'Amazing coffee!'

    within('.review-container', text: 'Amazing coffee!') do
      accept_confirm do
        click_on 'Delete this Review'
      end
    end

    assert_no_text 'Amazing coffee!'
  end

  test 'A logged in user can favorite and unfavorite a coffeeshop' do
    visit '/login'

    assert_selector 'h1', text: 'Login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    visit new_search_path

    assert_selector 'form.search-bar-container'
    fill_in 'search[query]', with: 'coffee'

    first('form button[type="submit"]').click

    wait_for_search_results
    click_more_info_safely

    toggle_detail_favorite('Add to favorites', 'Remove from favorites')
    toggle_detail_favorite('Remove from favorites', 'Add to favorites')

    assert_detail_favorite_state('Add to favorites')
  end

  test 'Yelp brand compliance - icon and color must be maintained' do
    visit coffeeshop_path(@coffeeshop, locale: nil)
    
    assert_selector 'svg.fa-yelp.yelp_color'
    assert_link 'View on Yelp', href: @coffeeshop.yelp_url

    yelp_icon = find('svg.fa-yelp.yelp_color')
    computed_style = yelp_icon.evaluate_script("window.getComputedStyle(this).getPropertyValue('color')")

    assert_includes computed_style, '255, 26, 26', 
                    'Yelp icon must maintain brand red color (#ff1a1a) for licensing compliance'
  end
end
