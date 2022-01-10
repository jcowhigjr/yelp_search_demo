require 'test_helper'

class CoffeeshopsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @coffeeshop = coffeeshops(:one)
  end

  # test "should not get index" do
  #   #  fyi no route
  #   # get coffeeshops_index_url
  #   # assert_response :fail
  # end

  test "should get show" do
    get "/coffeeshops/#{@coffeeshop.id}"
    assert_response :success
  end

end
