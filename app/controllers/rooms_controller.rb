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
      @user.touch
      @user.save
    else
      new_user_setting
      log_in @user
    end
    @rooms = Room.all
    @room_tags = RoomTag.all
  end

  def new
  end

  def create
    room_tag_setting
    if @room_name == ""
      room_setting
    else
      @room = Room.create(name: @room_name)
    end

    if @form_tags
      tags = @form_tags.split("#")
      tags.shift()
      tags.each do |tag|
        RoomTag.create(room_id: @room.id, name: tag)
      end
    end

    redirect_to room_path(@room.id)
  end

  private

    def room_tag_setting
      @room_name = params[:name][0]
      @form_tags = params[:room_tags][0]
    end

    def room_setting
      @room = Room.create(name: "ROOM")
      @room.name = "ROOM#{@room.id}"
      @room.save
    end

end
