require "application_system_test_case"

class SearchesTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit searches_url
  
    assert_selector "h1", text: "Search"
  end
end
