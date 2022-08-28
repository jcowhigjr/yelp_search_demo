require 'test_helper'

class CoffeeshopTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @coffeeshop = coffeeshops(:one)
  end
  test 'coffeeshop attributes must not be empty' do
    @coffeeshop.rating = nil
    assert_not @coffeeshop.valid?
  end
  test 'coffeeshop rating must be between 1 and 5' do
    assert_predicate @coffeeshop, :valid?
    @coffeeshop.rating = 0
    assert_not @coffeeshop.valid?
    @coffeeshop.rating = 5.5
    assert_not @coffeeshop.valid?
    @coffeeshop.rating = 1.5
    assert_predicate @coffeeshop, :valid?
    @coffeeshop.rating = 1
    assert_predicate @coffeeshop, :valid?
  end
end
