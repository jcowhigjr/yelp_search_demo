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
      post users_path,
           params: {
             user: {
               name: 'new user',
               email: 'new_user@example.com',
               password: 'mylongerpassword',
               password_confirmation: 'mylongerpassword',
             },
           }
    end
    assert_redirected_to static_home_url
    assert_equal 'Successfully created user.', flash[:success]
  end

  test '#show' do
    user_one = login(:one)
    assert_equal 'Successfully logged in.', user_one.flash[:success]
  end

  test '#destroy' do
    skip 'not implemented'

    user_one = login(:one)
    # assert_equal 'Successfully logged in.', user_one.flash[:success]
    assert_difference('User.count', -1) { user_one.delete '/users/1' }
    assert_equal 'User 1 destroyed', user_one.flash[:notice]
    assert_redirected_to '/login'
  end

  test '#:show, missing user' do
    user_one = login(:one)
    assert_equal 'Successfully logged in.', user_one.flash[:success]
    User.find_by(id: user_one.session[:user_id]).destroy

    # rescue ActiveRecord::RecordNotFound
    get '/users/1'
    assert_redirected_to static_home_url
  end

  test '#:show, cookie present missing current user' do
    user_one = login(:one)
    assert_equal 'Successfully logged in.', user_one.flash[:success]
    User.find_by(id: user_one.session[:user_id]).destroy

    # rescue ActiveRecord::RecordNotFound
    get static_home_url
  end

  private

  module CustomAssertions
    def favorite_coffeeshop(coffeeshop)
      # reference a named route, for maximum internal consistency!
      post user_favorites_path,
           params: {
             coffeeshop_id: coffeeshop.id,
           },
           as: :turbo_stream
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

      sess.post '/sessions',
                params: {
                  email: who.email,
                  password: 'TerriblePassword',
                }
    end
  end
end
