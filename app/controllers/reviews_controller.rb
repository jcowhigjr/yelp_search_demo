class ReviewsController < ApplicationController
  before_action :find_or_redirect, except: [:create]
  helper_method :permission?

  def index
    find_or_redirect
  end

  def create
    @coffeeshop = Coffeeshop.find(params[:coffeeshop_id])
    @review = @coffeeshop.reviews.create(review_params)
    if @review.save
      redirect_to @coffeeshop
    else
      flash[:review_error] = t('error.something_went_wrong')
      render @coffeeshop
    end
  end

  def edit
    @coffeeshop = Coffeeshop.find(@review.coffeeshop_id)
  end

  def update
    @review.update(review_params)
    if @review.save
      redirect_to @review.coffeeshop
    else
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(:review, partial: 'reviews/form',
                                                           locals: { review: @review })
      end
      flash[:error] = t('error.something_went_wrong')
      render @review.coffeeshop
    end
  end

  def destroy
    @coffeeshop = @review.coffeeshop
    @review.destroy
    redirect_to @coffeeshop
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating, :user_id, :coffeeshop_id)
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
      redirect_to coffeeshop_path(params[:coffeshop_id])
    else
      redirect_to static_home_url
    end

  end
end
