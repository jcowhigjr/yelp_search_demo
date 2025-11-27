require 'application_system_test_case'

class CoffeeshopsTest < ApplicationSystemTestCase
  include ActionView::Helpers::NumberHelper

  setup do
    @user = users(:two)
    @coffeeshop = coffeeshops(:two)
    @review = reviews(:two)
  end

  test 'An unauthenticated user can view coffeeshop details' do
    visit coffeeshop_path(@coffeeshop, locale: nil)

    assert_current_path %r{^/coffeeshops/\d{1,9}}
    assert_selector 'h1', text: @coffeeshop.name

    # About section
    within('[data-testid="about-section"]') do
      assert_link @coffeeshop.address,
                  href:
                    "https://www.google.com/maps/search/?api=1&query=#{@coffeeshop.google_address_slug}"
      assert_link number_to_phone(@coffeeshop.phone_number, area_code: true),
                  href: "tel:#{number_to_phone(@coffeeshop.phone_number, area_code: true)}"
      assert_link 'View on Yelp', href: @coffeeshop.yelp_url
    end

    # Rating and reviews section container still present
    assert_selector '.review-container', minimum: 1, wait: 5
  end

  test 'A logged in user can submit a review' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    assert_current_path '/sessions'

    # Search for a shop
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'

    assert_selector(:field, 'search[query]', with: 'coffee')
    first('button[type="submit"]').click

    assert_current_path search_path(Search.last.id, locale: nil)
    wait_for_search_results
    click_more_info_safely

    # Add to favorites - ensure button is visible and clickable
    assert_selector('input[type="submit"][value="Add To Favorites"]')
    click_on('Add To Favorites')

    assert_selector('input[type="submit"][value="Remove From Favorites"]')

    # Submit a review
    select '★★★★★', from: 'review[rating]'
    fill_in 'review[content]', match: :first, with: 'Great coffee!'

    click_on 'SUBMIT REVIEW'

    assert_text 'Great coffee!'
  end

  test 'A logged in user can edit and delete their review' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    assert_current_path '/sessions'

    # Visit the fixture coffeeshop directly
    visit coffeeshop_path(@coffeeshop, locale: nil)

    assert_current_path %r{^/coffeeshops/\d{1,9}}

    # Find and click edit within the review container
    within('.review-container', text: 'Cold Brew is the best') do
      click_on 'Edit this Review'
      
      # Form should appear in the Turbo frame
      assert_selector('form')
      fill_in 'review[content]', with: 'Amazing coffee!'
      click_on 'SUBMIT REVIEW'
    end

    # The page should not change, but content should update
    assert_current_path %r{^/coffeeshops/\d{1,9}}
    assert_text 'Amazing coffee!'

    # Delete the review - with Turbo confirmation
    within('.review-container', text: 'Amazing coffee!') do
      accept_confirm do
        click_on 'Delete this Review'
      end
    end

    # After deletion, the review should be gone
    assert_no_text 'Amazing coffee!'
  end

  test 'A logged in user can favorite and unfavorite a coffeeshop' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Search for a shop
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'

    # Use the first submit button in the search form to avoid ambiguous "search" matches
    first('form button[type="submit"]').click

    # Find and click the first More Info link
    wait_for_search_results
    click_more_info_safely


    # Add to favorites
    assert_selector('input[type="submit"][value="Add To Favorites"]')
    click_on 'Add To Favorites'

    # Remove from favorites
    assert_selector('input[type="submit"][value="Remove From Favorites"]')
    click_on 'Remove From Favorites'

    # Verify we can add to favorites again
    assert_selector('input[type="submit"][value="Add To Favorites"]')
  end
end
