class UsersController < ApplicationController
    before_action :redirect_if_logged_in, except: [:show]

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
        if @user.valid?
            @user.save
            session[:user_id] = @user.id
            redirect_to @user
        else
            flash[:error] = "Handle this error."
            render :new
        end
    end

    def show
        @user = User.find(params[:id])
    end

    private
    
    def user_params
        params.require(:user).permit(:name, :location, :email, :password, :password_confirmation)
    end
    
    

end
