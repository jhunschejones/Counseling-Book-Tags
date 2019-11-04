class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.unconfirmed_email || @user.email, subject: 'Welcome to Counseling Book Tags!')
  end

  def password_reset_email(user)
    @user = user
    mail(to: @user.email, subject: 'Password Reset Request')
  end
end
