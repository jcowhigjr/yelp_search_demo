require 'test_helper'

class UserFavoritesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @coffeeshop = coffeeshops(:one)
    @user_favorite = user_favorites(:one)
    @coffeeshop2 = coffeeshops(:two)
  end

  # test "should not get index" do
  #   #  fyi no route
  #   # get coffeeshops_index_url
  #   # assert_response :fail
  # end

  # test 'should respond with favorites with a user' do
  #   # user_favorite_url = user_favorites_url(@user_favorite.user)
  #   get user_favorite_url(@user_favorite)
  #   assert_response :success
  # end

  # test 'should get index' do  # fyi no route
  # end

  # test 'should get new' do
  #   binding.break
  # end

  test 'should get destroy' do
    # get user_favorites_destroy_url
    # assert_response :success
  end
end
