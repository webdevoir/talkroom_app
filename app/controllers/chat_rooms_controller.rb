class ChatRoomsController < ApplicationController
  def show
    @chat_room = ChatRoom.find(params[:id])
    @chats = @chat_room.chats
  end
end
