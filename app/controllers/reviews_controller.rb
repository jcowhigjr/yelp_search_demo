class ReviewsController < ApplicationController
  before_action :find_or_redirect, except: [:create]
  helper_method :permission?

  def index
    find_or_redirect
  end

  def edit
    @coffeeshop = Coffeeshop.find(@review.coffeeshop_id)
  end

  def create
    @coffeeshop = Coffeeshop.find(params[:coffeeshop_id])
    @review = @coffeeshop.reviews.create(review_params)
    if @review.save
      redirect_to @coffeeshop
    else
      flash.now[:error] = t('error.something_went_wrong')
      render @coffeeshop
    end
  end

  def update
    @coffeeshop = @review.coffeeshop

    if @review.update(review_params)
      respond_to_success
    else
      flash.now[:error] = t('error.something_went_wrong')
      respond_to_failure
    end
  end

  def respond_to_success
    respond_to do |format|
      format.html { redirect_to @coffeeshop }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          @review,
          partial: 'reviews/show',
          locals: { review: @review },
        )
      end
    end
  end

  def respond_to_failure
    # rubocop:disable Metrics/BlockLength
    respond_to do |format|
      format.html { render :edit, status: :unprocessable_entity }
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.replace(
            @review,
            partial: 'reviews/edit_frame',
            locals: { review: @review, coffeeshop: @coffeeshop },
          ),
          status: :unprocessable_entity,
        )
      end
    end
    # rubocop:enable Metrics/BlockLength
  end

  def destroy
    @coffeeshop = @review.coffeeshop
    @review.destroy
    redirect_to @coffeeshop
  end

  private

  def review_params
    params.expect(review: [:content, :rating, :user_id, :coffeeshop_id])
  end

  def set_review
    @review = Review.find_by(id: params[:id])
  end

  def permission?
    @review.user == current_user
  end

  def find_or_redirect
    set_review
    return unless @review.nil?

    if params[:coffeeshop_id]
      redirect_to coffeeshop_path(params[:coffeeshop_id])
    else
      redirect_to static_home_url
    end

  end
end
