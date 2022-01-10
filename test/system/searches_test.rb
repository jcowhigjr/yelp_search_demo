require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase
  test 'An anonymous user at the static home can search by zip to return a list of coffeeshops from yelp api' do
    visit static_home_url
    fill_in('query', with: '30312')
    click_button('Search')
    click_on('More Info', match: :first)
    assert_current_path %r{^/coffeeshops/\d{1,9}}
  end
end
