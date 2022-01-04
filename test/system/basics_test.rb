require "application_system_test_case"

class BasicsTest < ApplicationSystemTestCase
  test "getting started" do
    visit static_home_url
    fill_in('query', with: '30312')
    click_on 'Search'
    click_link('More Info', match: :first)
    click_on 'logged in'
    fill_in 'Email', with: 'user1@example.com'
    fill_in 'Password', with: 'TerriblePassword'
    click_on 'Log In'
    fill_in 'review[content]', with: 'this place is pretty cool'
    magic_test
    click_on 'Submit Review'
    assert_text 'this place is pretty cool'
  end
end
