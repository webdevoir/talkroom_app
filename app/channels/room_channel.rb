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
    message = Message.new(content: data['message'], user_id: current_user.id,
      user_name: current_user.name, room: Room.find(params['room_id']))
    if data['file_uri']
      message.attachment_name = data['original_name']
      message.attachment_data_uri = data['file_uri']
    end
    message.save
    user_update
    room_update
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
