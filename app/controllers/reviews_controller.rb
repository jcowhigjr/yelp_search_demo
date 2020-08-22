class ReviewsController < ApplicationController
    before_action :set_review, except: [:create]
    helper_method :has_permission
    def create
        @coffeeshop = Coffeeshop.find(params[:coffeeshop_id])
        @coffeeshop.reviews.build(review_params)
        if @coffeeshop.save
            redirect_to @coffeeshop
        else
            flash[:error] = "Something went wrong creating review"
            redirect_to @coffeeshop
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
            redirect_to @review.coffeeshop
        end
    end

    def destroy
        @coffeeshop = @review.coffeeshop
        @review.destroy
        redirect_to @coffeeshop
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
