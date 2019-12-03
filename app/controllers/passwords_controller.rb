class PasswordsController < ApplicationController
  skip_before_action :authenticate_user

  def new
  end

  def forgot
    if params[:email].blank?
      return redirect_to login_url, alert: 'Email not present'
    end

    user = User.find_by(email: params[:email])

    if user.present?
      user.generate_password_reset_token!
      UserMailer.password_reset_email(user).deliver_later
    end
    # Do not tell the user if an account exists for a specified email
    redirect_to login_url, notice: 'Please check your email for a password reset link'
  end

  def reset
    token = params[:token]

    if token.blank?
      flash[:alert] = "Token not present. Please try following the link from your reset email."
      return redirect_to login_url
    end

    if params[:password].blank? || params[:password_confirmation].blank? || params[:email].blank?
      flash[:alert] = "Enter your email and confirm your new password"
      redirect_to password_reset_path(token: params[:token]) and return
    end

    if params[:password] != params[:password_confirmation]
      flash[:alert] = "Your new password and confirmation must match"
      redirect_to password_reset_path(token: params[:token]) and return
    end

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password])
        redirect_to login_url, notice: "Password successfully reset! Please log in with your new password."
      else
        render :new, alert: user.errors.full_messages
      end
    else
      redirect_to login_url, alert: "Invalid or expired link. Please check your email or generate a new link."
    end
  end
end
