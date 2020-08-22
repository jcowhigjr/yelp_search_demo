class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, except: [:destroy]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      redirect_to user
    else
      redirect_to login_path, errors: "Something went wrong logging in."
    end
  end

  def destroy
    session.clear
    redirect_to root_path
  end

  def create_with_google
    auth = request.env["omniauth.auth"]["info"]
    user = User.find_or_create_by(email: auth["email"]) do |u|
      u.name = auth["name"]
      u.password = SecureRandom.hex
    end
    session[:user_id] = user.id
    redirect_to user_path(user)
  end
end
