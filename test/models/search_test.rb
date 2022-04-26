require 'test_helper'
require 'minitest/autorun'

class SearchTest < ActiveSupport::TestCase
  test 'the truth' do
    assert true
  end

  test 'should not save without a location' do
    search = Search.new
    assert_not search.save
  end

  test 'should not save without a query' do
    search = Search.new
    assert_not search.save
  end

  test 'should not save without a user' do
    search = Search.new
    assert_not search.save
  end

  test 'should save with a location and query' do
    search = Search.new
    search.query = 'yoga'
    assert_in_delta(search.latitude, 0.0)
    assert_in_delta(search.longitude, 0.0)
    assert search.save
  end
end
