require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @coffeeshop = coffeeshops(:one)
  end

  test 'review is valid with valid attributes' do
    review = Review.new(
      user: @user,
      coffeeshop: @coffeeshop,
      rating: 4,
      content: 'Great coffee!'
    )
    assert review.valid?
  end

  test 'review requires rating' do
    review = Review.new(
      user: @user,
      coffeeshop: @coffeeshop,
      content: 'Great coffee!'
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], "can't be blank"
  end

  test 'review rating must be between 1 and 5' do
    review = Review.new(
      user: @user,
      coffeeshop: @coffeeshop,
      content: 'Great coffee!',
      rating: 0
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], 'is not included in the list'

    review.rating = 6
    assert_not review.valid?
    assert_includes review.errors[:rating], 'is not included in the list'

    review.rating = 1
    assert review.valid?

    review.rating = 5
    assert review.valid?
  end

  test 'review requires content' do
    review = Review.new(
      user: @user,
      coffeeshop: @coffeeshop,
      rating: 4
    )
    assert_not review.valid?
    assert_includes review.errors[:content], "can't be blank"
  end
end
