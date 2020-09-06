class ReviewsController < ApplicationController
    before_action :find_or_redirect, except: [:create, :index]
    helper_method :has_permission
    def index
        @reviews = Review.order_reviews(params[:user_id])
    end
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
            flash[:error] = "Error editing review. Please try again."
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
        params.require(:review).permit(:content, :rating, :user_id)
    end

    def set_review
        @review = Review.find_by(id: params[:id])
    end

    def has_permission
        @review.user == current_user
    end

    def find_or_redirect
        set_review
        if @review.nil?
            if params[:coffeeshop_id]
                redirect_to coffeeshop_path(params[:coffeshop_id])
            else
                redirect_to root_path
            end
        end
    end



end
