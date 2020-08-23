class CoffeeshopsController < ApplicationController
  def show
    cookies[:last_visited] = params[:id]
    @coffeeshop = Coffeeshop.find(params[:id])
  end
end
