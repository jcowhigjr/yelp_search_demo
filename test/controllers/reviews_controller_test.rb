require 'test_helper'

# FIXME: nested turbo streams need special treatment https://discuss.hotwired.dev/t/broadcasting-to-nested-turbo-frame-tag/3659/6

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @coffeeshop = coffeeshops(:one)
    @review = reviews(:one)
    @user = users(:one)

    original_asset_path_helper = ActionController::Base.helpers.method(:asset_path)
    @original_asset_path_helper = original_asset_path_helper

    ActionController::Base.helpers.define_singleton_method(:asset_path) do |source, *args|
      if source.to_s == 'tailwind.css' || source.to_s == 'tailwind'
        '/assets/tailwind.css'
      else
        original_asset_path_helper.call(source, *args)
      end
    end
  end

  teardown do
    ActionController::Base.helpers.define_singleton_method(:asset_path, @original_asset_path_helper)
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

    assert_response :unprocessable_content
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

    assert_response :unprocessable_content
    assert_equal 'text/vnd.turbo-stream.html', @response.media_type

    assert_turbo_stream action: :replace, target: @review, status: :unprocessable_content do |fragment|
      assert_select fragment, "turbo-frame##{ActionView::RecordIdentifier.dom_id(@review)}" do
        assert_select 'form'
        assert_select '*', text: /Edit your review for/
      end
    end
  end

  test 'should destroy the user review' do
    assert_difference('Review.count', -1) do
      delete user_review_path(@user, @review, locale: nil)
    end

    assert_redirected_to coffeeshop_path(@coffeeshop)
  end

  test 'should show validation errors for invalid rating on create' do
    login_as(@user)
    @user.stubs(:favorite?).returns(false)
    
    assert_no_difference('Review.count') do
      post coffeeshop_reviews_path(@coffeeshop, locale: nil),
           params: {
             review: {
               user_id: @user.id,
               rating: 10,
               content: 'Great place!',
             },
           }
    end

    assert_response :unprocessable_content
    assert_includes @response.body, 'Please fix the following errors:'
    assert_includes @response.body, 'Rating is not included in the list'
  end
end
