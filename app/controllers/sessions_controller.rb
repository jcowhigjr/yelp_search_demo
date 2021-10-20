class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, except: [:destroy]
  require 'debug'
  def new; end

  def create
    user = User.find_by(email: session_params[:email])

    if user&.authenticate(session_params[:password])
      session[:user_id] = user.id
      flash[:success] = 'Logged in!'
      redirect_to_proper_path
    else
      flash[:error] = 'Your email or password do not match our records.'
      redirect_to login_path
    end
  end

  def destroy
    session.clear
    # redirect_to_proper_path
    redirect_to static_home_path, notice: 'Goodbye'
  end

  def create_with_google
    auth = request.env['omniauth.auth']['info']
    user = User.find_or_create_by(email: auth['email']) do |u|
      u.name = auth['name']
      u.password = SecureRandom.hex
    end
    session[:user_id] = user.id
    redirect_to_proper_path
  end

  private

  def redirect_to_proper_path
    if cookies[:last_visited]
      redirect_to coffeeshop_path(cookies[:last_visited])
    else
      render 'static/home', locals: { search: @search }
    end
  end

  # UsersTest#test_updating_a_User:
  # ActionController::ParameterMissing: param is missing or the value is empty: user
  def session_params
    params.permit(:email, :password, :password_confirmation)
  end
end
