class SearchesController < ApplicationController
  def new
    @search = Search.new
  end

  def update
    @search = Search.find(params[:id])
    @search.update!(search_params)
    redirect_to @search
  end

  def create
    @search ||= Search.new(search_params)

    @search.user = current_user if logged_in?

    raise 'Search not valid' unless @search.valid?

    if Coffeeshop.get_search_results(@search) == 'error'
      flash[:error] = t('something_went_wrong')
      redirect_to static_home_url
    else
      @search.save
      flash[:success] = t('success.create', model: 'search')
      redirect_to_proper_path
    end
  end

  def show
    @search = Search.find(params[:id])
  end

  # def index
  #   if current_user
  #     @searches = current_user.searches
  #   else
  #     @searches = Search.all
  #   end
  # end

  private

  def search_params
    params.require(:search).permit(:query, :latitude, :longitude)
  end

  def redirect_to_proper_path
    redirect_to @search
  end
end
