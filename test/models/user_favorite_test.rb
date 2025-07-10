require 'test_helper'

class UserFavoriteTest < ActiveSupport::TestCase
  test 'should be valid' do
    user_favorite = UserFavorite.new
user_favorite.user = users(:one)
    user_favorite.coffeeshop = coffeeshops(:one)

    assert_predicate user_favorite, :valid?
  end
end
