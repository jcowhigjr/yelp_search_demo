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
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Search for a shop
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'
    click_on 'Search'

    sleep 2 if ENV['CUPRITE'] == 'true'

    click_on 'More Info', match: :first

    # Debug output
    puts page.html

    # Add to favorites
    assert_selector('input[type="submit"][value="Add To Favorites"]')
    click_on 'Add To Favorites'

    # Submit a review
    fill_in 'review[content]', with: 'Great coffee!'
    click_on 'SUBMIT REVIEW'

    assert_text 'Great coffee!'
  end

  test 'A logged in user can edit and delete their review' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_on 'Log In'

    # Search for a shop
    visit new_search_path
    fill_in 'search[query]', with: 'coffee'
    click_on 'Search'
    sleep 2 if ENV['CUPRITE'] == 'true'

    click_on 'More Info', match: :first

    # Debug output
    puts page.html

    # Add to favorites
    assert_selector('input[type="submit"][value="Add To Favorites"]')
    click_on 'Add To Favorites'

    # Submit a review
    fill_in 'review[content]', with: 'Great coffee!'
    click_on 'SUBMIT REVIEW'

    # Edit the review
    click_on 'Edit'
    fill_in 'review[content]', with: 'Amazing coffee!'
    click_on 'Update Review'

    assert_text 'Amazing coffee!'

    # Delete the review
    accept_confirm do
      click_on 'Delete'
    end

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
    click_on 'Search'
    sleep 2 if ENV['CUPRITE'] == 'true'

    click_on 'More Info', match: :first

    # Debug output
    puts page.html

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
