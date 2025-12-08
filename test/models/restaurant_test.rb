require 'test_helper'

class RestaurantTest < ActiveSupport::TestCase
  setup do
    @restaurant = Restaurant.new(
      name: 'Test Restaurant',
      address: '123 Test St',
      rating: 4.0,
      yelp_url: 'https://yelp.com/test',
      image_url: 'https://example.com/image.jpg',
      phone_number: '555-1234',
    )
  end

  test 'restaurant attributes must not be empty' do
    restaurant = Restaurant.new

    assert_not restaurant.valid?
    assert_predicate restaurant.errors[:name], :any?
    assert_predicate restaurant.errors[:address], :any?
    assert_predicate restaurant.errors[:rating], :any?
    assert_predicate restaurant.errors[:yelp_url], :any?
    assert_predicate restaurant.errors[:image_url], :any?
    assert_predicate restaurant.errors[:phone_number], :any?
  end

  test 'valid restaurant with rating between 1.0 and 5.0' do
    assert_predicate @restaurant, :valid?
  end

  test 'rating must be greater than or equal to 1.0' do
    @restaurant.rating = 0.9

    assert_not @restaurant.valid?
    assert_includes @restaurant.errors[:rating], 'must be greater than or equal to 1.0'

    @restaurant.rating = 0

    assert_not @restaurant.valid?

    @restaurant.rating = -1

    assert_not @restaurant.valid?
  end

  test 'rating must be less than or equal to 5.0' do
    @restaurant.rating = 5.1

    assert_not @restaurant.valid?
    assert_includes @restaurant.errors[:rating], 'must be less than or equal to 5.0'

    @restaurant.rating = 6

    assert_not @restaurant.valid?

    @restaurant.rating = 10

    assert_not @restaurant.valid?
  end

  test 'rating at boundary values should be valid' do
    @restaurant.rating = 1.0

    assert_predicate @restaurant, :valid?

    @restaurant.rating = 5.0

    assert_predicate @restaurant, :valid?
  end

  test 'rating with decimal values between 1.0 and 5.0 should be valid' do
    [1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5].each do |rating|
      @restaurant.rating = rating

      assert_predicate @restaurant, :valid?, "Rating #{rating} should be valid"
    end
  end

  test 'rating cannot be nil' do
    @restaurant.rating = nil

    assert_not @restaurant.valid?
    assert_predicate @restaurant.errors[:rating], :any?
  end
end
