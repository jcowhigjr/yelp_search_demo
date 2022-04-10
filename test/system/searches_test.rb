require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase
  test 'An anonymous user at the static home can search by zip to return a list of coffeeshops from yelp api' do
    query = 'yoga'

    visit static_home_url

    fill_in 'search[query]', with: query

    # required fields are present
    assert_selector(:field, 'search_query', with: query)

    assert_selector(:field, 'search_latitude', type: 'hidden')
    assert_selector(:field, 'search_longitude', type: 'hidden')

    if ENV['SHOW_TESTS'] && !ENV['CUPRITE']
      # sleeping for a second to allow the geolocation api call to complete
      sleep 4
      # need to stub the geolocation api call default is 0.0
      assert_no_selector(:field, 'search_latitude', type: 'hidden', with: '0.0')
      assert_no_selector(:field, 'search_longitude', type: 'hidden', with: '0.0')

    else
      # use default geolocation values
      assert_selector(:field, 'search_latitude', type: 'hidden', with: '0.0')
      assert_selector(:field, 'search_longitude', type: 'hidden', with: '0.0')
    end

    # submit the form
    find('#search_query').native.send_keys(:return)

    # wait for the results to load
    assert_text "Top Rated Searches for #{query} near you"

    assert_selector('address') # address is present')

    assert_selector :link, text: 'phone'
    # assert_link 'phone', href: "tel:#{@coffeeshop.phone_number}"
    assert_selector :link, text: 'place'
    # assert_link 'place', href: "https://www.google.com/maps/search/?api=1&query=#{@coffeeshop.google_address_slug}"

    click_on('More Info', match: :first)

    assert_current_path %r{^/coffeeshops/\d{1,9}}
    go_back
    assert_current_path "/searches/#{Search.last.id}"

    # try a second search
    click_on 'clear'

    query2 = 'coffee'

    fill_in 'search_query', with: query2

    # required fields are present
    assert_selector(:field, 'search_query', with: query2)

    # submit the form
    find('#search_query').native.send_keys(:return)

    assert_text "Top Rated Searches for #{query2} near you"

    assert_selector('address')  # address is present'
  end
end
