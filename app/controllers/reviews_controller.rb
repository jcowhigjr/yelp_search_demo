class ReviewsController < ApplicationController

    def create
        @coffeehop = Coffeeshop.find(params[:coffeeshop_id])
        @coffeeshop.reviews.build(review_params)
        if @coffeshop.save
            redirect_to @coffeshop
        else
            flash[:error] = "Something went wrong creating review"
            redirect_to @coffeeshop
        end
    end

private

    def review_params
        params.require(:review).permit(:content, :rating, :user_id)
    end
end
