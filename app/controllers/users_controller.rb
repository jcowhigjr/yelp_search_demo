class UsersController < ApplicationController
  before_action :redirect_if_logged_in, except: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      @user.save
      session[:user_id] = @user.id
      flash[:success] = 'User Created!'
      redirect_to_proper_path
    else
      flash[:error] = 'Something went wrong during signup.'
      render :new
    end
  end

  def show
    cookies[:last_viewed] = nil
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def redirect_to_proper_path
    if cookies[:last_visited]
      redirect_to coffeeshop_path(cookies[:last_visited])
    else
      # TODO: create show user path and redirect to current_user
      redirect_to static_home_path
    end
  end
end
