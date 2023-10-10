# app/controllers/users_controller.rb

class UsersController < ApplicationController
  before_action :authenticate_user!

  # Display a list of users
  def index
    @users = User.all
  end

  # Show a specific user's details
  def show
    @user = User.find(params[:id])
  end

  # Display the form for editing a user's role
  def edit
    @user = User.find(params[:id])
  end

  # Update a user's role
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: 'User role updated successfully.'
    else
      render :edit
    end
  end

  # Display the form for editing a user's role (admin only)
  def admin_edit_user
    @user = User.find(params[:id])
  end

  # Update a user's role (admin only)
  def admin_update_user
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_path, notice: 'User role updated successfully.'
    else
      render :admin_edit_user
    end
  end

  private

  def user_params
    params.require(:user).permit(:role)
  end
end

