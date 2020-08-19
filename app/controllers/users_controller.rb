class UsersController < ApplicationController
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
        require_login
        @user = User.find(params[:id])
    end

    private
    
    def user_params
        params.require(:user).permit(:name, :location, :email, :password, :password_confirmation)
    end
    def require_login
        redirect_to login_path unless logged_in?
    end

end
