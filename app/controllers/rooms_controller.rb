class RoomsController < ApplicationController
  def show
    @room = Room.find(params[:id])
    @messages = @room.messages
  end

  def index
    if !logged_in?
      new_user_setting
      log_in @user
    elsif User.exists?(id: current_user.id)
      @user = current_user
    else
      new_user_setting
      log_in @user
    end
  end

  def new
  end

  def create
  end

  def destroy
  end
end
