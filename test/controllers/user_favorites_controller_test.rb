require 'test_helper'

class UserFavoritesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @coffeeshop = coffeeshops(:one)
    @user = users(:one)
    @user_favorite = user_favorites(:one)
    @coffeeshop2 = coffeeshops(:two)
  end

  test 'add favorite should remain on coffeeshop page' do
    user_one = login(:one)

    assert_equal 'Successfully logged in.', user_one.flash[:success]
    user_one.favorite_coffeeshop(@coffeeshop)

    assert_equal 'Coffeeshop is added to your favorites.',
                 user_one.flash[:success]
    assert_equal coffeeshop_path(@coffeeshop), user_one.path
  end

  test 'should destroy favorite' do
    user_one = login(:one)

    assert_equal 'Successfully logged in.', user_one.flash[:success]
    assert_equal '/login', path
    user_one.unfavorite_coffeeshop(@coffeeshop)

    assert_equal 'Successfully destroyed coffeeshop.',
                 user_one.flash[:success]
    assert_response :success
    assert_equal coffeeshop_path(@coffeeshop), user_one.path
  end

  private

  module CustomAssertions
    def favorite_coffeeshop(coffeeshop)
      post user_favorites_path,
           params: {
             coffeeshop_id: coffeeshop.id,
           },
           as: :turbo_stream
      follow_redirect!
    end

    def unfavorite_coffeeshop(coffeeshop)
      delete user_favorite_path(id: coffeeshop.id), as: :turbo_stream
      follow_redirect!
    end
  end

  def login(who)
    open_session do |sess|
      sess.extend(CustomAssertions)
      who = users(who)
      get '/login'

      assert_response :success

      sess.post '/sessions',
                params: {
                  email: who.email,
                  password: 'TerriblePassword',
                }
    end
  end
end
