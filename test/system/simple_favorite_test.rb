require "application_system_test_case"

class SimpleFavoriteTest < ApplicationSystemTestCase
  test "can click favorite button" do
    user = users(:one)
    
    visit static_home_path
    fill_in 'email', with: user.email
    fill_in 'password', with: default_password
    click_button 'Log in'
    
    fill_in 'search[query]', with: 'coffee'
    find('button[type="submit"]').click
    
    assert_selector '.coffeeshop-card', wait: 10
    
    # Find and click the favorite button
    favorite_frame = find("[id^='favorite_']", match: :first)
    within favorite_frame do
      button = find('button.favorite-btn')
      puts "Before click: #{button.text}"
      button.click
    end
    
    # Wait and check what happened
    sleep 2
    puts "Page HTML after click:"
    puts page.html
    
    # Try to find the frame again
    if has_selector?("[id^='favorite_']")
      puts "Frame still exists"
    else
      puts "Frame disappeared"
    end
  end
end
