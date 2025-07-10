require 'test_helper'

# require 'minitest/autorun'
# require 'minitest/focus'

# FIXME: nested turbo streams need special treatment https://discuss.hotwired.dev/t/broadcasting-to-nested-turbo-frame-tag/3659/6

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @coffeeshop = coffeeshops(:one)
    @review = reviews(:one)
    @user = users(:one)
  end

  test 'should create review' do
    assert_difference('Review.count') do
      post coffeeshop_reviews_path(@coffeeshop, locale: nil),
           params: {
             review: {
               user_id: @user.id,
               rating: @review.rating,
               content: @review.content,
             },
           }
    end

    assert_redirected_to coffeeshop_path(@coffeeshop)
  end

  test 'should destroy the user review' do
    assert_difference('Review.count', -1) do
      delete user_review_path(@user, @review, locale: nil)
    end

    assert_redirected_to coffeeshop_path(@coffeeshop)
  end
end
