class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    if params['chat_room_id'].present?
      stream_from "chat_room_channel_#{params['chat_room_id']}"
      current_chat_room = ChatRoom.find(params['chat_room_id'])
      if current_chat_room.user1_id.nil?
        current_chat_room.user1_id = current_user.id
        current_chat_room.save
      elsif current_chat_room.user2_id.nil?
        current_chat_room.user2_id = current_user.id
        current_chat_room.save
      else
        redirect_to rooms_path
      end
      greet
    end
  end

  def unsubscribed
    current_chat_room = ChatRoom.find(params['chat_room_id'])
    if current_chat_room.user1_id == current_user.id
      current_chat_room.user1_id = nil
    elsif current_chat_room.user2_id == current_user.id
      current_chat_room.user2_id = nil
    end
    current_chat_room.save
    if current_chat_room.user1_id == nil && current_chat_room.user2_id == nil
      current_chat_room.destroy
    end
    farewell_greet
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

    def greet
      Chat.create(content: "#{current_user.name}が入室しました。", user_id: current_user.id,
      user_name: current_user.name, chat_room: ChatRoom.find(params['chat_room_id']))
    end

    def farewell_greet
      Chat.create(content: "#{current_user.name}が退出しました。", user_id: current_user.id,
      user_name: current_user.name, chat_room: ChatRoom.find(params['chat_room_id']))
    end

end
