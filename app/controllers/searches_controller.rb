class SearchesController < ApplicationController
  def new
    redirect_to Search.create
  end

  def update
    @search = Search.find(params[:id])
    @search.update(search_params)
    redirect_to @search
  end

  def create
    @search = determine_search_type
    if Coffeeshop.get_search_results(@search) == 'error'
      flash[:error] = 'Something went wrong with your search, please try again.'
      redirect_to static_home_url
    else
      @search.save!
      redirect_to_proper_path
    end
  end

  def show
    @search = Search.find(params[:id])
  end

  private

  def search_params
    params.permit(:search, :query, :latitude, :longitude)
  end

  def determine_search_type
    if logged_in?
      Search.new(search_params.merge(user: current_user))
    else
      Search.new(search_params)
    end
  end

  def redirect_to_proper_path
    if logged_in?
      redirect_to @search
    else
      render 'static/home', locals: { search: @search }, notice: 'Search created, please login to save your search.'
    end
  end
end
