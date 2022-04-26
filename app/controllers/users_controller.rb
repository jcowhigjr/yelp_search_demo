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
      flash[:success] = t('success.create', model: 'user')
      redirect_to_proper_path
    else
      flash[:error] = t('error.something_went_wrong')
      render :new
    end
  end

  def show
    cookies[:last_viewed] = nil
    @user = User.find(params[:id])
  end

  rescue_from ActiveRecord::RecordNotFound do
    flash[:error] = t('error.not_found')
    redirect_to static_home_url
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to user_path, notice: t.success.destroy(model: 'user')
  end

  private

  def user_params
    params
      .require(:user)
      .permit(:name, :email, :password, :password_confirmation)
  end

  def redirect_to_proper_path
    if cookies[:last_visited]
      redirect_to coffeeshop_path(cookies[:last_visited])
    else
      # TODO: create show user path and redirect to current_user
      redirect_to static_home_url
    end
  end
end
