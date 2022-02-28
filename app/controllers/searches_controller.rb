class SearchesController < ApplicationController
  def new
    @search = Search.create
    redirect_to @search
  end

  def create
    @search = determine_search_type
    if Coffeeshop.get_search_results(params[:query], @search) == 'error'
      flash[:error] = 'Something went wrong with your search, please try again.'
      redirect_to static_home_url
    else
      @search.save
      redirect_to_proper_path
    end
  end

  def show
    @search = Search.find(params[:id])
  end

  private

  def determine_search_type
    if logged_in?
      Search.create(query: params[:query], latitude: params[:latitude], longitude: params[:longitude],
                    user: current_user)
    else
      Search.create(
        latitude: params[:latitude], longitude: params[:longitude], query: params[:query]
      )
    end
  end

  def redirect_to_proper_path
    if logged_in?
      redirect_to @search
    else
      render 'static/home', locals: { search: @search }
    end
  end
end
