require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_favorite = user_favorites(:one)
    @user.name = 'John'
    # allow_any_instance_of(ActionDispatch::SystemTestCase).to receive(:current_user).and_return(users(:one))
    # @controller.stubs(:current_user).returns(users(:one))
    get '/login'
  end

  test '#create' do
    assert_difference('User.count') do
      post users_path, params: {
        user: { name: 'new user', email: 'new_user@example.com', password: 'mypass', password_confirmation: 'mypass' }
      }
    end
    assert_response :found
    assert_redirected_to static_home_path
    assert_equal 'User Created!', flash[:success]
  end
end
