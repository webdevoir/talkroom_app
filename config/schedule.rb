require File.expand_path(File.dirname(__FILE__) + "/environment")

rails_env = Rails.env.to_sym
rails_root = Rails.root.to_s

set :environment, rails_env
set :output, "#{rails_root}/log/cron.log"

every 1.day, at: '0:00 am' do
  runner "Room.auto_room_delete"
end

every 1.month do
  runner "User.auto_user_delete"
end

every 1.minute do
  runner "User.test"
end