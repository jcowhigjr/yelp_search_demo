class UserFavoritesController < ApplicationController
  def create
    user_fav = current_user.user_favorites.build(coffeeshop_id: params[:coffeeshop_id])
    if user_fav.save
      redirect_to current_user
    else
      flash[:error] = "Something went wrong when adding to your favorites."
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
