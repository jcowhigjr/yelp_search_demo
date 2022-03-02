require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase
  test 'An anonymous user at the static home can search by zip to return a list of coffeeshops from yelp api' do
    visit static_home_url
    fill_in('query', with: 'seafood')
    assert_selector(:field, 'query', with: 'seafood')
    sleep 5

    # need to stub the geolocation api call
    # assert_selector(:field, 'latitude', type: 'hidden', with: '35.91')
    # assert_selector(:field, 'longitude', type: 'hidden',  with: '-78.99')

    click_button('Search')

    click_on('More Info', match: :first)

    assert_current_path %r{^/coffeeshops/\d{1,9}}
  end
end
