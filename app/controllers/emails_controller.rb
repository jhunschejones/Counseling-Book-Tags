class EmailsController < ApplicationController
  skip_before_action :authenticate_user

  def verify
    token = params[:token]

    if token.blank?
      flash[:alert] = "Token not present. Please try following the link from your verification email."
      return redirect_to login_url
    end

    user = User.find_by(email_verification_token: token)

    if user.present?
      if user.verify_email!
        if user.unconfirmed_email
          user.update(email: user.unconfirmed_email, unconfirmed_email: nil)
        end
        redirect_to login_url, notice: "Email successfully verified! Please log in to use your account."
      else
        render :new, alert: user.errors.full_messages
      end
    else
      redirect_to login_url, alert: "Link not valid or expired. Use 'forgot password' to generate a new link."
    end
  end
end
