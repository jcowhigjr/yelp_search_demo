require 'test_helper'

class CoffeeshopsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @coffeeshop = coffeeshops(:two)
  end

  test 'should get show' do
    get "/coffeeshops/#{@coffeeshop.id}"

    assert_response :success
    assert_select 'h1', @coffeeshop.name
    assert_select 'a.truncate', text: @coffeeshop.address
  end
end
