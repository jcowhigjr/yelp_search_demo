require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase

  test 'An anonymous user at the static home can search by zip to return a list of coffeeshops from yelp api' do

    query = 'yoga'

    visit static_home_url
    fill_in('query', with: query)
    assert_selector(:field, 'query', with: query)

    if ENV['SHOW_TESTS'] && !ENV['CUPRITE']
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

    assert_text "Top Rated Searches for #{query}"

    click_on('More Info', match: :first)

    assert_current_path %r{^/coffeeshops/\d{1,9}}
  end
end
