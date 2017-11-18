class PasswordResetsController < ApplicationController
  before_action :user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render :new
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render :edit
    elsif @user.update(user_params)
      log_in @user
      @user.update(:reset_digest, nil)
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :passsword_confirmation)
  end

  def user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    return if @user &. activated? &. authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = 'Password reset has expired.'
    redirect_to new_password_reset_url
  end
end
