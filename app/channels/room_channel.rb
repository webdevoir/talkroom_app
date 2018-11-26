class RoomChannel < ApplicationCable::Channel
  def subscribed
    if params['room_id'].present?
      stream_from "room_channel_#{params['room_id']}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    puts data['message']
    if current_user
      message = Message.new(content: data['message'], user_id: current_user.id,
        user_name: current_user.name, room: Room.find(params['room_id']))
      if data['file_uri']
        message.attachment_name = data['original_name']
        message.attachment_data_uri = data['file_uri']
      end
      message.save
      user_update
      room_update
    else
      user = User.find(data['user_id'])
      if user.name != data['user_name']
        user.name = data['user_name']
        user.save
      end
      message = Message.new(content: data['message'], user_id: user.id,
        user_name: user.name, room: Room.find(params['room_id']))
      message.save
      room_update
    end
  end

  private
    def user_update
      user = current_user
      user.touch
      user.save
    end

    def room_update
      room = Room.find(params['room_id'])
      room.touch
      room.save
    end
end
