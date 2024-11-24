require 'test_helper'

class CoffeeshopCreationTest < ActionDispatch::IntegrationTest
  setup do
    @coffeeshop_params = {
      name: 'New Coffeeshop',
      address: '123 Main St',
      phone_number: '123-456-7890',
      rating: 5, # Assuming rating is required and should be between 1 and 5
    }
  end

  test 'creating a new coffeeshop' do
    assert_difference 'Coffeeshop.count', 1 do
      post coffeeshops_path, params: { coffeeshop: @coffeeshop_params }
    end

    follow_redirect!

    # Check if the response is successful
    assert_response :success
    assert_match 'Coffeeshop was successfully created.', @response.body
    assert_match 'New Coffeeshop', @response.body
  end

end
