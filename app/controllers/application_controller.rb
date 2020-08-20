class ApplicationController < ActionController::Base
    helper_method :current_user, :logged_in?, :check_login

    def current_user
        session[:user_id] ? User.find(session[:user_id]) : nil
    end

    def logged_in?
        !!current_user
    end

    def check_login
        redirect_to root_path unless logged_in?
    end

    def redirect_if_logged_in
        redirect_to current_user if logged_in?
    end

    

end
