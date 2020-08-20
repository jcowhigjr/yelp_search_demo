class UserFavoritesController < ApplicationController
  def create
    current_user.user_favorites.build(coffeeshop_id: params[:coffeeshop_id])
    if current_user.save
      redirect_to current_user
    else
      flash[:error] = "Handle this error"
      redirect_to current_user
    end
  end

  def destroy
    set_user_favorite
    @user_favorite.destroy
    redirect_to current_user
  end

  private

  def set_user_favorite
    @user_favorite = UserFavorite.find_by(coffeeshop_id: params[:coffeeshop_id], user_id: current_user.id)
  end
end
