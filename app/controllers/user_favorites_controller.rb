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
  end
end
