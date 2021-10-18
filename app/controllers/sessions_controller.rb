class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, except: [:destroy]

  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
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

  # def redirect_to_proper_path
  #   if logged_in?
  #     redirect_to @search
  #   else
  #     render 'static/home', locals: { search: @search }
  #   end
  # end
end
