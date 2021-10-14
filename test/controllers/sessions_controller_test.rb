require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get login_url
    assert_response :success
  end
#TODO: move tests for session
  # test "should get create" do
  #   get sessions_create_url
  #   assert_response :success
  # end

  # test "should get destroy" do
  #   get sessions_destroy_url
  #   assert_response :success
  # end

end
