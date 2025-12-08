require 'test_helper'

class RestaurantTest < ActiveSupport::TestCase
  test 'should accept valid rating of 1.0' do
    restaurant = Restaurant.new(name: 'Test Restaurant', rating: 1.0)

    assert_predicate restaurant, :valid?
  end

  test 'should accept valid rating of 5.0' do
    restaurant = Restaurant.new(name: 'Test Restaurant', rating: 5.0)

    assert_predicate restaurant, :valid?
  end

  test 'should accept valid rating between 1.0 and 5.0' do
    restaurant = Restaurant.new(name: 'Test Restaurant', rating: 3.5)

    assert_predicate restaurant, :valid?
  end

  test 'should reject rating less than 1.0' do
    restaurant = Restaurant.new(name: 'Test Restaurant', rating: 0.9)

    assert_not restaurant.valid?
    assert_includes restaurant.errors[:rating], 'must be greater than or equal to 1.0'
  end

  test 'should reject rating greater than 5.0' do
    restaurant = Restaurant.new(name: 'Test Restaurant', rating: 5.1)

    assert_not restaurant.valid?
    assert_includes restaurant.errors[:rating], 'must be less than or equal to 5.0'
  end

  test 'should reject negative rating' do
    restaurant = Restaurant.new(name: 'Test Restaurant', rating: -1.0)

    assert_not restaurant.valid?
    assert_includes restaurant.errors[:rating], 'must be greater than or equal to 1.0'
  end

  test 'should accept nil rating' do
    restaurant = Restaurant.new(name: 'Test Restaurant', rating: nil)

    assert_predicate restaurant, :valid?
  end
end
