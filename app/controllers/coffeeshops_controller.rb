class CoffeeshopsController < ApplicationController

  def index
    if params[:query]
      @coffeeshops = helpers.get_search_results(params[:query])
    else

    end
  end

  def show
  end


end
