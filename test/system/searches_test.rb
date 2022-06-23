require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase

  test 'An anonymous user at the static home can search by query and requery for businesses' do
    query = 'yoga'

    visit '/'

    fill_in 'search[query]', with: query

    # required fields are present
    assert_selector(:field, 'search_query', with: query)

    assert_selector(:field, 'search_latitude', type: 'hidden')
    assert_selector(:field, 'search_longitude', type: 'hidden')

    if ENV.fetch('SHOW_TESTS', nil) && !ENV['CUPRITE']
      # sleeping for a second to allow the geolocation api call to complete
      sleep 4

      # need to stub the geolocation api call default is 0.0
      assert_no_selector(:field, 'search_latitude', type: 'hidden', with: '0.0')
      assert_no_selector(
        :field,
        'search_longitude',
        type: 'hidden',
        with: '0.0',
      )
    else
      # use default geolocation values
      assert_selector(:field, 'search_latitude', type: 'hidden', with: '0.0')
      assert_selector(:field, 'search_longitude', type: 'hidden', with: '0.0')
    end

    # submit the form
    find('#search_query').native.send_keys(:return)

    # wait for the results to load
    wait_for_network_idle! if ENV['CUPRITE'] == 'true'

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

    assert_selector(:field, 'search_query', with: '')

    query2 = 'coffee'

    fill_in 'search_query', with: query2

    # required fields are present
    assert_selector(:field, 'search_query', with: query2)

    # submit the form
    find('#search_query').native.send_keys(:return)

    # wait for the results to load
    wait_for_network_idle! if ENV['CUPRITE'] == 'true'

    assert_text "Top Rated Searches for #{query2} near you"

    assert_selector('address') # address is present'
  end

  test 'An anonymous user can update the query' do
    query = 'yoga'

    visit '/'

    fill_in 'search[query]', with: query

    # required fields are present
    assert_selector(:field, 'search_query', with: query)

    assert_selector(:field, 'search_latitude', type: 'hidden')
    assert_selector(:field, 'search_longitude', type: 'hidden')

    if ENV.fetch('SHOW_TESTS', nil) && (ENV['CUPRITE'] != 'true')
      # sleeping for a second to allow the geolocation api call to complete
      sleep 4

      # need to stub the geolocation api call default is 0.0
      assert_no_selector(:field, 'search_latitude', type: 'hidden', with: '0.0')
      assert_no_selector(
        :field,
        'search_longitude',
        type: 'hidden',
        with: '0.0',
      )
    else
      # use default geolocation values
      assert_selector(:field, 'search_latitude', type: 'hidden', with: '0.0')
      assert_selector(:field, 'search_longitude', type: 'hidden', with: '0.0')
    end

    # submit the form
    find('#search_query').native.send_keys(:return)

    # wait for the results to load
    wait_for_network_idle! if ENV['CUPRITE'] == 'true'

    assert_text "Top Rated Searches for #{query} near you"

    assert_selector('address') # address is present')

    assert_selector :link, text: 'phone'

    # assert_link 'phone', href: "tel:#{@coffeeshop.phone_number}"
    assert_selector :link, text: 'place'

    # assert_link 'place', href: "https://www.google.com/maps/search/?api=1&query=#{@coffeeshop.google_address_slug}"

    query2 = 'coffee'

    fill_in 'search_query', with: query2

    # required fields are present
    assert_selector(:field, 'search_query', with: query2)

    # submit the form
    find('#search_query').native.send_keys(:return)

    # wait for the results to load
    wait_for_network_idle! if ENV['CUPRITE'] == 'true'

    assert_text "Top Rated Searches for #{query2} near you"

    assert_selector('address') # address is present'
  end

end
