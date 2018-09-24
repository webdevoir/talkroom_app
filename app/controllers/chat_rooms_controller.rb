class ChatRoomsController < ApplicationController
  def show
    @chat_room = ChatRoom.find(params[:id])
    @chats = @chat_room.chats
  end

  def index
    @free_user1_chat_room = ChatRoom.where(user1_id: nil).where.not(user2_id: nil)
    @free_user2_chat_room = ChatRoom.where.not(user1_id: nil).where(user2_id: nil)
    if @free_user2_chat_room.nil?
      redirect_to controller: "chat_rooms", action: "show", id: @free_user1_chat_room.first.id
      # @access_chat_room = @free_user1_chat_room.first
      # redirect_to chat_room_path(@access_chat_room.id)
    elsif @free_user1_chat_room.nil?
      redirect_to controller: "chat_rooms", action: "show", id: @free_user2_chat_room.first.id
      # params[:id] = @free_user2_chat_room.first.id
      # redirect_to chat_room_path(id: params[:id])
      # @access_chat_room = @free_user2_chat_room.first
      # redirect_to chat_room_path(@access_chat_room.id)
    else
      @new_chat_room = ChatRoom.create
      redirect_to controller: "chat_rooms", action: "show", id: @new_chat_room.id
    end
  end
end
