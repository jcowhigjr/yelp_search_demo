require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_favorite = user_favorites(:one)
    @user.name = 'John'
    # allow_any_instance_of(ActionDispatch::SystemTestCase).to receive(:current_user).and_return(users(:one))
    # @controller.stubs(:current_user).returns(users(:one))
    get '/login'
  end

  test '#create' do
    assert_difference('User.count') do
      post users_path, params: {
        user: { name: 'new user', email: 'new_user@example.com', password: 'mypass', password_confirmation: 'mypass' }
      }
    end
    assert_response :found
    assert_redirected_to static_home_url
    assert_equal 'User Created!', flash[:success]
  end

  test '#show' do
    user_one = login(:one)
    assert_equal 'Logged in!', user_one.flash[:success]
  end

  test '#destroy' do
    skip 'not implemented'
    user_one = login(:one)
    assert_equal 'Logged in!', user_one.flash[:success]
    assert_difference('User.count', -1) do
      user_one.delete '/users/1'
    end
    assert_equal 'User 1 destroyed', user_one.flash[:notice]
    assert_response :success
    assert_equal '/login', user_one.current_path
  end

  test '#:show, bug missing user' do
    user_one = login(:one)
    assert_equal 'Logged in!', user_one.flash[:success]
    User.find_by(id: user_one.session[:user_id]).destroy
    skip 'this is the bug'
    # ActiveRecord::RecordNotFound
    # get '/users/1'
  end


  private

  module CustomAssertions
    def favorite_coffeeshop(coffeeshop)
      # reference a named route, for maximum internal consistency!
      post user_favorites_path, params: { coffeeshop_id: coffeeshop.id }, as: :turbo_stream
      follow_redirect!
    end

    def unfavorite_coffeeshop(coffeeshop)
      # binding.break unless coffeeshop
      # reference a named route, for maximum internal consistency!
      # https://github.com/hotwired/turbo-rails/blob/main/test/streams/streams_controller_test.rb#L38
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

      sess.post '/sessions', params: { email: who.email,
                                       password: 'TerriblePassword' }
    end
  end
end
