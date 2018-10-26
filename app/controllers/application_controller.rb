class ApplicationController < ActionController::Base
  helper_method :current_user

  def current_user
    if session[:uid] && session[:provider]
      @user ||= User.where(:provider => session['provider'],
                           :uid => session['uid'].to_s).first

    else
      @user = nil
    end
  end
end
