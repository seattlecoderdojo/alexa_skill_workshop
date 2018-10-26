class SessionsController < ApplicationController
  def create
    @user = User.where(:provider => auth['provider'],
                       :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    session[:uid] = auth['uid']
    session[:provider] = auth['provider']

    redirect_to user_path(@user)
  end

  protected

  def auth
    request.env['omniauth.auth']
  end
end
