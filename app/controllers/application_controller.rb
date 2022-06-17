class ApplicationController < ActionController::Base
  include Locales

  helper_method :current_user, :logged_in?, :check_login

  around_action :set_locale
  helper_method :resolve_locale

  def current_user
    session[:user_id] ? User.find(session[:user_id]) : nil
  end

  def logged_in?
    !!current_user
  end

  def check_login
    redirect_to static_home_url unless logged_in?
  end

  def redirect_if_logged_in
    redirect_to current_user if logged_in?
  end
end
