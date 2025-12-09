require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  test 'is invalid when rating is below 1' do
    review = Review.new(
      content: 'Too low',
      rating: 0,
      user: users(:one),
      coffeeshop: coffeeshops(:one),
    )

    assert_not review.valid?
    assert_includes review.errors[:rating], 'must be greater than or equal to 1'
  end

  test 'is invalid when rating is above 5' do
    review = Review.new(
      content: 'Too high',
      rating: 5.5,
      user: users(:one),
      coffeeshop: coffeeshops(:one),
    )

    assert_not review.valid?
    assert_includes review.errors[:rating], 'must be less than or equal to 5'
  end

  test 'is valid when rating is within the allowed range' do
    review = Review.new(
      content: 'Just right',
      rating: 4,
      user: users(:one),
      coffeeshop: coffeeshops(:one),
    )

    assert_predicate review, :valid?
  end
end
