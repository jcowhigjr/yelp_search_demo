require 'test_helper'

class ReviewsController::RoutesTest < ActionController::TestCase
  def test_user_review_routes
    assert_routing '/users/1/reviews', controller: 'reviews', action: 'index', user_id: '1'
    # assert_routing '/users/1/reviews/new', controller: 'reviews', action: 'new_review'
    # assert_routing '/users/1/reviews/1', controller: 'reviews', action: 'show_review', user_id: '1', review_id: '1'
    # assert_routing '/users/1/reviews/1/edit', controller: 'reviews', action: 'edit_review', id: '1', review_id: '1'
    # assert_routing '/users/1/reviews/1/update', controller: 'reviews', action: 'update_review', id: '1', review_id: '1'
    # assert_routing '/users/1/reviews/1/destroy', controller: 'reviews', action: 'destroy_review', id: '1', review_id: '1'
  end
end
