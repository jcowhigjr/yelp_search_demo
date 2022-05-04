require 'application_system_test_case'

class UsersTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @user_favorite = user_favorites(:one)
    # allow_any_instance_of(ActionDispatch::SystemTestCase).to receive(:current_user).and_return(users(:one))
    # @controller.stubs(:current_user).returns(users(:one))
  end

  test 'sign up and sign out' do
    visit '/'
    visit 'users/new'
    fill_in 'user_name', with: 'john'
    fill_in 'user_email', with: 'john@example.com'
    fill_in 'user_password', with: 'sadfkjs342'
    fill_in 'user_password_confirmation', with: 'sadfkjs342'
    click_on 'commit'

    click_on 'Logout' # this is not working
    assert_current_path '/'
  end

  test 'manual sign in' do
    Capybara.disable_animation = true
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
    # it prompts for user login instead and then says "This browser or app may not be secure."
    # so we need to click on the "Continue" button
    # click_on 'Continue'
    # click_on 'My Profile'
    # assert_text "Hello, #{@user.name}"
    # click_link 'Logout'
  end
end
