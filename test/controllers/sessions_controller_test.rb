require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test 'should get login' do
    get login_url

    assert_response :success
  end

  setup do
    @user = users(:two)
    @user.password = default_password
    @user.password_confirmation = default_password
    @user.save!
  end

  test 'should sign in user' do
    post sessions_path,
         params: {
           email: @user.email,
           password: default_password,
         }

    assert_response :ok
    assert_equal 'Successfully logged in.', flash[:success]
  end

  test 'should redirect to login on fail' do
    post sessions_path,
         params: {
           email: @user.email,
           password: 'badd password',
         }

    assert_response :found
    assert_equal 'Your email or password do not match our records.',
                 flash[:error]
    assert_redirected_to login_path
  end

end
