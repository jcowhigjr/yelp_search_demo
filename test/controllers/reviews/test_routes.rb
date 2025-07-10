require 'test_helper'

class ReviewsController::RoutesTest < ActionDispatch::IntegrationTest
  def test_user_review_routes
    assert_routing '/users/1/reviews', controller: 'reviews', action: 'index', user_id: '1'
  end
end
