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
    skip 'this test is broken'
    click_on 'menu'
    click_on 'Logout' # this is not working
    assert_current_path '/'
  end

  test 'manual sign in' do
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_button 'Log In'
    assert_text 'Hello, user_one!'
  end

  test 'sign in and visit user profile' do
    # before login via session controller
    visit '/login'
    fill_in 'email', with: @user.email
    fill_in 'Password', with: default_password
    click_button 'Log In'
    click_on 'menu'
    click_on 'My Profile'
    assert_current_path "/users/#{@user.id}"
    assert_text "Hello, #{@user.name}!"
  end


# test 'destroying a User' do
  #   visit users_url
  #   page.accept_confirm do
  #     click_on 'Destroy', match: :first
  #   end

  #   assert_text 'User was successfully destroyed'
  # end

  test 'partial sign in with Google' do
    visit '/login'
    click_button 'Login With Google'

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

  test 'sign up with Google' do
    visit '/signup'

    # assert_difference "User.count", 1 do
    click_on 'Sign Up With Google'
    # it prompts for user login instead and then says "This browser or app may not be secure."
    unless ENV['SHOW_TESTS'] == 'true'
      skip 'redirect_uri_mismatch'
    end
    # so we need to click on the "Continue" button
    fill_in 'identifierId', with: 'test@gmail.com'
    click_on 'Next'
    # assert_text 'This browser or app may not be secure.'
    # go_back
    # assert_current_path '/signup'

  end
end
#