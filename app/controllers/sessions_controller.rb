class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      redirect_to user
    else
      flash[:errors] = "Incorrect email or password."
      redirect_to login_path
    end
  end

  def destroy
    session.clear
    Search.destroy_all
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
