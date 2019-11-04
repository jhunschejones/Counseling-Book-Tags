class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [:new, :create]

  def new
    @user = User.new
  end

  def show
  end

  def edit
  end

  def update
    if params[:user][:name] != @user.name
      @user.update(name: params[:user][:name])
    elsif params[:user][:email] != @user.email
      # need to verify it's okay to update email in a way that is
      # secure and won't leave users locked out of their accounts
      users_with_email = User.where("email = :email AND id != :id OR unconfirmed_email = :email AND id != :id", email: params[:user][:email], id: @user.id)

      if users_with_email.empty?
        @user.unconfirmed_email = params[:user][:email]
        @user.generate_email_verification_token!
        UserMailer.welcome_email(@user).deliver_later
        flash[:notice] = "Please follow the verification link sent to your new email to confirm the change"
      else
        flash[:alert] = "Emails must be unique, please request a password reset if you cannot access your account"
        redirect_to edit_user_path(@user) and return
      end

    end

    redirect_to user_path(@user)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.generate_email_verification_token!
      UserMailer.welcome_email(@user).deliver_later
      redirect_to login_url, notice: "User #{@user.email} was successfully created. Please follow the verification link in your email."
    else
      render :new
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
