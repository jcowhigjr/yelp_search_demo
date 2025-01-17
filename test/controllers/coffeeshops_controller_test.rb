require 'test_helper'

class CoffeeshopsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @coffeeshop = coffeeshops(:two)
  end

  test 'should get show' do
    get "/coffeeshops/#{@coffeeshop.id}"

    assert_response :success
    assert_select 'h1', text: @coffeeshop.name
    assert_select 'address', contain_text: "place#{@coffeeshop.address}"
  end
end
