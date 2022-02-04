require 'test_helper'

require "minitest/autorun"
require "minitest/focus"
# require "minitest/retry"
# Minitest::Retry.use!

# Minitest::Retry.on_failure do |klass, test_name, result|
#   ENV['MAGIC_TEST'] = 'true'
# end

#FIXME: nested turbo streams need special treatment https://discuss.hotwired.dev/t/broadcasting-to-nested-turbo-frame-tag/3659/6

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

  # test "create with respond to" do
  #   post messages_path
  #   assert_redirected_to message_path(id: 1)

  #   post messages_path, as: :turbo_stream
  #   assert_no_turbo_stream action: :update, target: "messages"
  #   assert_turbo_stream status: :created, action: :append, target: "messages" do |selected|
  #     assert_equal "<template>message_1</template>", selected.children.to_html
  #   end
  # end

  test 'should create review' do
    login(@user)
    assert_difference('Review.count') do
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
    
    # assert_select 'p', text: @review.content
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
  skip "not implemented"
    login(@user)
    assert_no_difference('Review.count') do
      assert_difference('Review.find(@review.id).content', 'edited') do
        patch user_review_path(@user, @review),
          params: {
              review: {
                user_id: @user.id,
                rating: @review.rating + 1,
                content: "#{@review.content}edited"
              }
            }
      end
      assert_select 'span', text: '★☆☆☆☆'
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
