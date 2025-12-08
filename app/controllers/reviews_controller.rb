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
    @review = @coffeeshop.reviews.build(review_params)
    if @review.save
      redirect_to @coffeeshop
    else
      render 'coffeeshops/show', status: :unprocessable_content
    end
  end

  def update
    @coffeeshop = @review.coffeeshop

    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @coffeeshop }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@review,
                                                    partial: 'reviews/show',
                                                    locals: { review: @review })
        end
      else
        flash.now[:review_error] = t('error.something_went_wrong')

        format.html { render :edit, status: :unprocessable_content }
        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(@review,
                                               partial: 'reviews/edit_frame',
                                               locals: { review: @review, coffeeshop: @coffeeshop }),
            status: :unprocessable_content,
          )
        end
      end
    end
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
      redirect_to coffeeshop_path(params[:coffeshop_id])
    else
      redirect_to static_home_url
    end

  end
end
