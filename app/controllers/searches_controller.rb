class SearchesController < ApplicationController
  # Skip CSRF verification in development for IDE proxy origins (e.g., Windsurf preview)
  skip_before_action :verify_authenticity_token, if: :development_ide_preview?

  def show
    @search = Search.find(params[:id])
  end

  def new
    @search = Search.new
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

  def update
    @search = Search.find(params[:id])
    @search.coffeeshops = []
    @search.update!(search_params)
    if Coffeeshop.get_search_results(@search) == 'error'
      flash[:error] = t('something_went_wrong')
      redirect_to static_home_url
    else
      @search.save
      flash[:success] = t('success.update', model: 'search')
      redirect_to_proper_path
    end
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
    params.expect(search: [:query, :latitude, :longitude])
  end

  def redirect_to_proper_path
    redirect_to @search
  end

  def development_ide_preview?
    Rails.env.development? && request.headers['Origin']&.match?(/127\.0\.0\.1:\d+/)
  end
end
