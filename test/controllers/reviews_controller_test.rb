require 'test_helper'

# FIXME: nested turbo streams need special treatment https://discuss.hotwired.dev/t/broadcasting-to-nested-turbo-frame-tag/3659/6

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @coffeeshop = coffeeshops(:one)
    @review = reviews(:one)
    @user = users(:one)
    ActionController::Base.helpers.stubs(:asset_path).returns('/assets/tailwind.css')
  end

  def login_as(user)
    ApplicationController.any_instance.stubs(:current_user).returns(user)
    ApplicationController.any_instance.stubs(:logged_in?).returns(true)
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

  test 'updates review and redirects on html success' do
    login_as(@user)

    patch user_review_path(@user, @review, locale: nil),
          params: {
            review: {
              content: 'Updated thoughts on espresso',
              rating: 4,
            },
          }

    assert_redirected_to coffeeshop_path(@review.coffeeshop)
    assert_equal 'Updated thoughts on espresso', @review.reload.content
  end

  test 'renders edit with errors on html failure' do
    login_as(@user)

    patch user_review_path(@user, @review, locale: nil),
          params: {
            review: {
              content: '',
              rating: '',
            },
          }

    assert_response :unprocessable_entity
    assert_equal I18n.t('error.something_went_wrong'), flash[:review_error]
    assert_includes @response.body, 'Edit your review for'
  end

  test 'returns turbo stream with form on failure for turbo clients' do
    login_as(@user)

    patch user_review_path(@user, @review, locale: nil),
          params: {
            review: {
              content: '',
              rating: '',
            },
          },
          headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

    assert_response :unprocessable_entity
    assert_equal 'text/vnd.turbo-stream.html', @response.media_type
    assert_includes @response.body, '<turbo-stream action="replace"'
    assert_includes @response.body,
                    "<turbo-frame id=\"#{ActionView::RecordIdentifier.dom_id(@review)}\""
    assert_includes @response.body, 'Edit your review for'
  end

  test 'should destroy the user review' do
    assert_difference('Review.count', -1) do
      delete user_review_path(@user, @review, locale: nil)
    end

    assert_redirected_to coffeeshop_path(@coffeeshop)
  end
end
