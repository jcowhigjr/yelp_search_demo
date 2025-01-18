require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @user_favorite = user_favorites(:one)
  end

  test 'sign up and sign out' do
    visit '/signup'
    fill_in 'user_name', with: 'john'
    fill_in 'user_email', with: 'john@example.com'
    fill_in 'user_password', with: 'sadfkjs342'
    fill_in 'user_password_confirmation', with: 'sadfkjs342'
    click_on 'commit'


    if ENV['CUPRITE'] == 'true'
      # Use JavaScript to click the menu
      find_by_id('menu').trigger('click')

      # Use JavaScript to click Logout
      find('a', text: 'Logout').trigger('click')
    else
      click_on 'menu'
      click_on 'Logout'
    end

    assert_current_path '/'
  end

  test 'manual sign in' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_link_or_button 'Log In'

    assert_text 'Hello, user_one!'
  end

  test 'sign in and visit user profile' do
    # before login via session controller
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_link_or_button 'Log In'
    # after login click on the hamburger menu only visible in mobile view
    # how to simluate mobile click in headless mode?
    #

    click_on 'My Profile'

    assert_current_path "/users/#{@user.id}"
    assert_text "Hello, #{@user.name}!"
  end

  test 'partial sign in with Google' do
    visit '/login'
    click_link_or_button 'Login With Google'

    unless ENV['SHOW_TESTS'] == 'true'
      skip 'redirect_uri_mismatch'
    end
    # it prompts for user login instead and then says "This browser or app may not be secure."
    # so we need to click on the "Continue" button
    fill_in 'identifierId', with: 'test@gmail.com'
    click_on 'Next'
    # assert_text 'This browser or app may not be secure.'
    # go_back
    # it prompts for user login instead and then says "This browser or app may not be secure."
    # so we need to click on the "Continue" button
    # click_on 'Cancel'
    # click_on 'My Profile'
    # assert_text "Hello, #{@user.name}"
    # click_link 'Logout'
  end
end
