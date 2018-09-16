class UsersController < ApplicationController
  def create
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to rooms_path
    else
      redirect_to rooms_path
    end
  end

  private

    def user_params
      params.require(:user).permit(:name)
    end
end
