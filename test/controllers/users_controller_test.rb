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

  test "the truth" do
    assert true
  end
end
