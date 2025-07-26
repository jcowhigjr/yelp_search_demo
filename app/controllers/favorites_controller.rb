class FavoritesController < ApplicationController
  include FavoritesHelper
  include ActionView::RecordIdentifier
  
  before_action :check_login
  before_action :set_item

  def create
    current_user.user_favorites.create!(coffeeshop: @item)
    set_button_variables
  end

  def destroy
    current_user.user_favorites.find_by(coffeeshop: @item)&.destroy
    set_button_variables
  end

  private

  def set_item
    @item = Coffeeshop.find(params[:id])
  end

  def set_button_variables
    @liked = current_user.favorited?(@item)
    @icon  = favorite_icon_for(params[:search_query])
  end
end
