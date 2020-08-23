class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, except: [:destroy]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to_proper_path
    else
      flash[:error] =  "Your email or password do not match our records."
      redirect_to login_path
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
    redirect_to_proper_path
  end

  def redirect_to_proper_path
      if cookies[:last_visited]
        redirect_to coffeeshop_path(cookies[:last_visited])
      else
        redirect_to current_user
      end
  end

end
