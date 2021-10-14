require 'application_system_test_case'

class SearchesTest < ApplicationSystemTestCase
  test 'Static Home Has a Search field' do
    visit static_home_url
    fill_in('query', :with => '30312')
    click_button('Search')
    #TODO: create a mock response from Yelp.
    page.should have_selector('.search-results > .row.center > .white-text')
    page.should have_content('Bellwood')
  end
end
