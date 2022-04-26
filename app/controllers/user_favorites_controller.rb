class UserFavoritesController < ApplicationController
  def create
    user_fav =
      current_user.user_favorites.build(coffeeshop_id: params[:coffeeshop_id])
    if user_fav.save
      flash[:success] = 'Coffeeshop is added to your favorites.'
      @coffeeshop = user_fav.coffeeshop
      redirect_to @coffeeshop
    else
      flash[:error] = t('error.something_went_wrong')
      redirect_to current_user
    end
  end

  def destroy
    set_user_favorite
    @coffeeshop = @user_favorite.coffeeshop
    if @user_favorite.destroy
      flash[:success] = t('success.destroy', model: 'coffeeshop')
      redirect_to @coffeeshop
    else
      flash[:error] = t('error.something_went_wrong')
      redirect_to current_user
    end
  end

  private

  def set_user_favorite
    @user_favorite =
      UserFavorite.find_by(coffeeshop_id: params[:id], user_id: current_user.id)
  end
end
