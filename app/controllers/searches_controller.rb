class SearchesController < ApplicationController

  def create
    @search = determine_search_type
    Coffeeshop.get_search_results(params[:query]).each{|i| @search.coffeeshops << i}
    if @search.save
      proper_path(@search)
    else
      redirect_to root_path, error: "Something went wrong with your search please try again."
    end
  end

  def show
    @search = Search.find(params[:id])
  end

  private

  def determine_search_type
    logged_in? ? Search.create(query: params[:query], user: current_user) : Search.create(query: params[:query])
  end

  def proper_path(search)
    if logged_in?
      redirect_to coffeeshops_path(@search.coffeeshops)
    else
      render "static/home", locals: {search: @search}
    end
  end
end
