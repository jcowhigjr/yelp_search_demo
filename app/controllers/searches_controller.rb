class SearchesController < ApplicationController

  def new
    @search = Search.create
    redirect_to @search
  end

  def create
    @search = determine_search_type
    associate_coffeeshops_to_search
    if @search.save
      proper_path
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

  def proper_path
    if logged_in?
      redirect_to @search
    else
      render "static/home", locals: {search: @search}
    end
  end

  def associate_coffeeshops_to_search
    Coffeeshop.get_search_results(params[:query]).each{|i| @search.coffeeshops << i}
  end

end
