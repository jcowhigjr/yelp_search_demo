require 'test_helper'

class CoffeeshopsController::RoutesTest < ActionController::TestCase

  def test_routes
    assert_routing '/', controller: 'static', action: 'home'
    assert_routing '/searches', controller: 'searches', action: 'new'
    assert_routing '/search/1', controller: 'searches', action: 'show', id: '1'
    assert_routing '/coffeeshops/1', controller: 'coffeeshops', action: 'show', id: '1'
    assert_routing '/users/1', controller: 'users', action: 'show', id: '1'

  end
end
