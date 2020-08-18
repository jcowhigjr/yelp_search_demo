require 'test_helper'

class CoffeeshopControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get coffeeshop_new_url
    assert_response :success
  end

  test "should get create" do
    get coffeeshop_create_url
    assert_response :success
  end

  test "should get index" do
    get coffeeshop_index_url
    assert_response :success
  end

  test "should get show" do
    get coffeeshop_show_url
    assert_response :success
  end

end
