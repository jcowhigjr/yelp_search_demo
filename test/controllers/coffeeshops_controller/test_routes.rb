require 'test_helper'

class CoffeeshopsController::RoutesTest < ActionController::TestCase

  # def setup
  #   @coffeeshop = Coffeeshop.create(name: 'Hello World')
  # end

  def test_routes
    # assert_routing '/posts',   controller: "posts", action: "index"
    assert_routing '/coffeeshops/1', controller: "coffeeshops", action: "show", id: "1"
  end

  # test "should not get index" do
  #   #  fyi no route
  #   # get coffeeshops_index_url
  #   # assert_response :fail
  # end

  # test "should get show" do
  #   get coffeeshop_show_url
  #   assert_response :success
  # end

end
