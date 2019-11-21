class UsersController < ApplicationController
  skip_before_action :authenticate_user, only: [:new, :create]

  def new
    @user = User.new
  end

  def show
    if params[:id].to_i != @user.id
      flash[:alert] = "You cannot access information for another user"
      redirect_to user_path(@user)
    end
  end

  def edit
    if params[:id].to_i != @user.id
      flash[:alert] = "You cannot edit information for another user"
      redirect_to edit_user_path(@user)
    end
  end

  def update
    if user_params[:name] && user_params[:name] != @user.name
      @user.update(name: user_params[:name])
    end

    if user_params[:email] && user_params[:email] != @user.email
      unless email_is_unique?
        flash[:alert] = "Emails must be unique, please request a password reset if you cannot access your account"
        return redirect_to edit_user_path(@user)
      end

      # securely verify new email without locking users out of their accounts
      @user.unconfirmed_email = user_params[:email]
      @user.generate_email_verification_token!
      UserMailer.welcome_email(@user).deliver_later
      flash[:notice] = "Please follow the verification link sent to your new email to confirm the change"
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
    def email_is_unique?
      User.where(
        "email = :email AND id != :id OR unconfirmed_email = :email AND id != :id",
        email: user_params[:email], id: @user.id).empty?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
