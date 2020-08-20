class CoffeeshopsController < ApplicationController
  def index
    if params[:query]
      Coffeeshop.get_search_results(params[:query])
      @coffeeshops = Coffeeshop.ordered_by_rating
      @search = params[:query]
    else
      @coffeeshops = Coffeeshop.all
    end
  end

  def show
    @coffeeshop = Coffeeshop.find(params[:id])
  end
end
