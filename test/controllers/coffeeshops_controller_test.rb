require 'test_helper'

class CoffeeshopsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get coffeeshops_index_url
    assert_response :success
  end

  test "should get show" do
    get coffeeshops_show_url
    assert_response :success
  end

end
