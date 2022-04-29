require 'test_helper'

class CoffeeshopsController::RoutesTest < ActionController::TestCase
  def test_routes
    assert_routing '/', controller: 'searches', action: 'new'
    assert_routing '/login', controller: 'sessions', action: 'new'
    assert_routing '/users/1', controller: 'users', action: 'show', id: '1'
  end

  def test_search_routes
    # assert_routing '/searches/new', controller: 'searches', action: 'new'
    # assert_routing '/searches', controller: 'searches', action: 'create'
    assert_routing '/searches/1',
                   controller: 'searches',
                   action: 'show',
                   id: '1'
  end

  def test_coffeeshop_routes
    assert_routing '/coffeeshops/1',
                   controller: 'coffeeshops',
                   action: 'show',
                   id: '1'
  end
end
