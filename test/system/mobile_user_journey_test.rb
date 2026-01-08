require 'application_system_test_case'

class MobileUserJourneyTest < ApplicationSystemTestCase
  driven_by :cuprite, screen_size: [375, 667], options: {
    browser_options: {
      'no-sandbox': true,
      'disable-web-security': true,
      'auto-open-devtools-for-tabs': false,
      'disable-popup-blocking': true,
      'disable-notifications': true,
      'use-fake-device-for-media-stream': true,
      'use-fake-ui-for-media-stream': true,
      'disable-gpu': true,
      'window-size': '375,667',
      geolocation: true,
    },
  } do |driver_option|
    driver_option.browser.command('Browser.grantPermissions', origin: 'http://127.0.0.1:*', 
permissions: ['geolocation'])
    driver_option.browser.command('Emulation.setGeolocationOverride', latitude: 40.7128, longitude: -74.0060, 
accuracy: 1)
  end

  setup do
    stub_yelp_api_request('tacos')
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

    assert_match 'google.com/maps', current_url
  end
end
