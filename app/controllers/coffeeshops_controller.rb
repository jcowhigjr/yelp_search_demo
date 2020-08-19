class CoffeeshopsController < ApplicationController
  def index
    if params[:query]
      @coffeeshops = Coffeeshop.get_search_results(params[:query])
      @search = params[:query]
    else
      @coffeeshops = Coffeeshop.all
    end
  end

  def show
  end
end
