class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_room_channel_#{params['chat_room_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    Chat.create(content: data['chat'], user_id: current_user.id,
      user_name: current_user.name, chat_room: ChatRoom.find(params['chat_room_id']))
    user_update
  end

  private
    def user_update
      user = current_user
      user.touch
      user.save
    end

end
