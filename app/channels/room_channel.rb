class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel_#{params['room_id']}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    Message.create(content: data['message'], user_id: current_user.id,
      user_name: current_user.name, room: Room.find(params['room_id']))
  end
end
