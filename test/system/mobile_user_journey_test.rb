require 'application_system_test_case'

class MobileUserJourneyTest < ApplicationSystemTestCase
  driven_by :cuprite_mobile

  setup do
    stub_yelp_api_request("tacos")
  end

  test 'a mobile user can share their location, search for tacos, and get directions' do
    visit '/'

    click_on 'my_location'
    fill_in 'search[query]', with: 'tacos'
    click_on 'Search'

    assert_selector '.coffeeshop-card'

    click_on 'Mock Taco Shop'

    assert_selector 'h1', text: 'Mock Taco Shop'

    new_window = window_opened_by do
      click_on 'GET DIRECTIONS'
    end

    switch_to_window(new_window)
    assert_match "google.com/maps", current_url
  end
end
