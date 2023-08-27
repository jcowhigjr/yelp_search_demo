require 'test_helper'

class UsersController::RoutesTest < ActionDispatch::IntegrationTest
  
  def test_user_routes
    assert_routing '/users/1', controller: 'users', action: 'show', id: '1'
    # assert_routing '/users/1/edit', controller: 'users', action: 'edit', id: '1'
    assert_routing '/signup', controller: 'users', action: 'new'

    assert_routing '/auth/google_oauth2/callback', controller: 'sessions', action: 'create_with_google'
    # assert_routing '/users', controller: 'users',
    # assert_routing '/users/1/destroy', controller: 'users', action: 'destroy', id: '1'
    # assert_routing  '/users', controller: 'users', action: 'index'
  end

end
