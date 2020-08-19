class ApplicationController < ActionController::Base

    def current_user
        session[:user_id] ? User.find(session[:user_id]) : nil
    end

    def logged_in?
        !!current_user
    end

    def require_login
        redirect_to login_path unless logged_in?
    end
end
