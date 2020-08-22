class CoffeeshopsController < ApplicationController
  def show
    @coffeeshop = Coffeeshop.find(params[:id])
  end
end
