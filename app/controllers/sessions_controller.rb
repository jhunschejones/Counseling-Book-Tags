class SessionsController < ApplicationController
  skip_before_action :authenticate_user

  def new
    if session[:user_id]
      redirect_to session.delete(:return_to) || user_path(session[:user_id])
    else
      render :new
    end
  end

  def create
    user = User.find_by(email: params[:email])

    if user && !user.is_verified
      redirect_to login_url, notice: "Please follow the email verification link to activate your account, or perform a password reset to generate a new link"
    elsif user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      flash.discard
      redirect_to session.delete(:return_to) || user_path(user)
    else
      redirect_to login_url, alert: "Invalid email/password combination"
    end
  end

  def destroy
    reset_session
    redirect_to login_url, notice: "Succesfully logged out"
  end
end
