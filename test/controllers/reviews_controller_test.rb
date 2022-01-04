require 'test_helper'
class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @coffeeshop = coffeeshops(:one)
    @review = reviews(:one)
    @user = users(:one)
  end

  # test 'should get index' do
  #   login(@user)
  #   # binding.b
  #   get coffeeshop_reviews_path(1)
  #   assert_response :success
  # end

  # test 'should get new' do
  #   get new_review_path
  #   assert_response :success
  # end

  test 'should create review' do
    login(@user)
    assert_difference('Review.count') do
      puts Review.count
      post coffeeshop_reviews_path(@coffeeshop),
           params: {
             review: {
               user_id: @user.id,
               rating: @review.rating,
               content: @review.content
             }
           }
    end
    assert_redirected_to coffeeshop_path(@coffeeshop)
  end

  # test 'should show review' do
  #   get review_path(@review)
  #   assert_response :success
  # end

  # test 'should get edit' do
  #   get edit_review_path(@review)
  #   assert_response :success
  # end

  test 'should edit this review' do
    login(@user)
    assert_no_difference('Review.count') do
      assert_difference('Review.find(@review.id).content', 'edited') do
        puts Review.count
        put coffeeshop_reviews_path(@coffeeshop),
            params: {
              review: {
                user_id: @user.id,
                rating: @review.rating,
                content: "#{@review.content}edited"
              }
            }
      end
    end

    assert_redirected_to coffeeshop_path(@coffeeshop)
  end

  test 'should destroy the user review' do # test for destroy
    # login(@user)
    assert_difference('Review.count', -1) do
      delete user_review_path(@user, @review) # delete ReviewsController#:destroy
    end

    assert_redirected_to coffeeshop_path(@coffeeshop)
  end
end
