class UserFavoritesController < ApplicationController
  def create
    user_fav = current_user.user_favorites.build(coffeeshop_id: params[:coffeeshop_id])
    if user_fav.save
      flash[:success] = "Coffeeshop is added to your favorites."
      redirect_to current_user
    else
      flash[:error] = "Something went wrong when adding to your favorites."
      redirect_to current_user
    end
  end

  def destroy
    set_user_favorite
    if @user_favorite.destroy
      flash[:success] = "Coffeeshop is removed from your favorites."
      redirect_to current_user
    else
      flash[:error] = "Something went wrong when removing your favorite."
      redirect_to current_user
    end
  end

  private

  def set_user_favorite
    @user_favorite = UserFavorite.find_by(coffeeshop_id: params[:id], user_id: current_user.id)
  end
end
