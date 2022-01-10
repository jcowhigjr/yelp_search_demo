require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test "should get index" do
    assert_login_access(url: '/users/1') do
      assert_redirected_to static_home_url
    end
  end
  test 'should get login' do

    get login_url
    assert_response :success
  end

  setup do
    @user = users(:two)
    @user.password = 'mypass'
    @user.password_confirmation = 'mypass'
    @user.save!
  end

  test 'should sign in user' do
    post sessions_path, params: {
      email: @user.email, password: 'mypass'
    }
    assert_response :ok
    assert_equal 'Logged in!', flash[:success]
  end

  test 'should redirect to login on fail' do
    post sessions_path, params: {
      email: @user.email, password: 'badd password'
    }
    assert_response :found
    assert_equal 'Your email or password do not match our records.', flash[:error]
    assert_redirected_to login_path
  end





#TODO: Mock the call to google
# https://coderwall.com/p/t_3hmq/linkedin-oauth2-login-for-rails
  # test 'should sign in user with google' do
  #   get google_login_url, params: {
  #     email: @user.email
  #   }
  #    assert_response :found
  #    assert_equal 'Logged in!', flash[:success]

  #   # assert_response :ok
  #   # assert_equal 'Logged in!', flash[:success]
  # end
end
