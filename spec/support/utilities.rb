def log_in(user)
    session[:user_id] = user.id
end

def log_out(user)
    session[:user_id] = nil
end

def message_create(user, room)
    message.user_id = user.id
    message.room_id = room.id
    message.save
end