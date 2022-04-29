require 'test_helper'
# frozen_string_literal: true


class ReviewsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @coffeeshop = coffeeshops(:one)
    @current_user = users(:one)

    # @user_review = user_reviews(:one)
    @coffeeshop2 = coffeeshops(:two)
    # @user_favorite_params = {@user: {favorite: "light"}}
  end

  test 'should update user settings' do
    true
    # assert_equal "dark", @current_user.theme

    # assert_self_access(
    #   user: @current_user,
    #   method: :patch,
    #   url: user_setting_url(@current_user),
    #   # params: @setting_params,
    #   xhr: true
    # ) do
    #   assert_equal "light", @current_user.reload.theme
    # end
  end

  # test "should not get index" do
  #   #  fyi no route
  #   # get coffeeshops_index_url
  #   # assert_response :fail
  # end

  # test 'should respond with reviews with a user' do
  #   # user_review_url = user_reviews_url(@user_review.user)
  #   get user_review_url(@user_review)
  #   assert_response :success
  # end

  # test 'should get index' do  # fyi no route
  # end

  # test 'should get new' do
  #   binding.break
  # end

  test 'should get destroy' do
    # get user_reviews_destroy_url
    # assert_response :success
  end
end
