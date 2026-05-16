class SearchesController < ApplicationController
  # CSRF protection is enforced for all actions, including development environment.
  # Removed skip_before_action directive to ensure security.

  def show
    @search = Search.find(params.expect(:id))
  end

  def new
    @search = Search.new
    record_return_visit
  end

  def create
    @search ||= Search.new(search_params)

    @search.user = current_user if logged_in?

    raise 'Search not valid' unless @search.valid?

    search_result = Coffeeshop.get_search_results(@search)
    if search_error_result?(search_result)
      handle_search_error(search_result)
    else
      handle_search_success
    end
  end

  def update
    @search = Search.find(params.expect(:id))
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

  def search_error_result?(search_result)
    search_result.is_a?(String) && search_result.start_with?('error')
  end

  def handle_search_error(search_result)
    record_search_error(@search)
    # Display generic error message; detailed errors are logged server-side
    flash[:error] = if search_result.include?('not configured')
      search_result  # Show API key setup message
    else
      t('something_went_wrong')  # Generic message for other errors
                    end
    redirect_to static_home_url
  end

  def handle_search_success
    @search.save
    record_search_success(@search)
    flash[:success] = t('success.create', model: 'search')
    redirect_to_proper_path
  end

  def record_search_success(search)
    OutcomeEvents.record(
      'search_success',
      user: current_user,
      payload: search_success_payload(search),
    )
  end

  def record_search_error(search)
    OutcomeEvents.record(
      'search_error',
      user: current_user,
      payload: {
        query: search.query,
        error_category: 'yelp_error',
      },
    )
  end

  def search_success_payload(search)
    {
      search_id: search.id,
      query: search.query,
      result_count: search.coffeeshops.size,
    }
  end

  def record_return_visit
    return unless logged_in?
    return if session[:outcome_return_visit_recorded]

    prior_search_count = current_user.searches.count
    return if prior_search_count.zero?

    OutcomeEvents.record(
      'return_visit',
      user: current_user,
      payload: { prior_search_count: },
    )
    session[:outcome_return_visit_recorded] = true
  end

  # Removed development_ide_preview? method as CSRF protection is now enforced universally.
end
