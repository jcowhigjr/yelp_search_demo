class ReviewsController < ApplicationController
    before_action :set_review, except: [:create]
    helper_method :has_permission
    def create
        @coffeeshop = Coffeeshop.find(params[:coffeeshop_id])
        @review = @coffeeshop.reviews.create(review_params)
        if @coffeeshop.save
            redirect_to @coffeeshop
        else
            flash[:review_error] = "Something went wrong with creating your review."
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
            flash[:error] = "Error editing review."
            render @review.coffeeshop
        end
    end

    def destroy
        @coffeeshop = @review.coffeeshop
        @review.destroy
        render @coffeeshop
    end


private

    def review_params
        params.require(:review).permit(:content, :rating, :user_id)
    end

    def set_review
        @review = Review.find(params[:id])
    end

    def has_permission
        @review.user == current_user
    end
end
