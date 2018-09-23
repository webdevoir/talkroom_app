class Chat < ApplicationRecord
  after_create_commit { ChatBroadcastJob.perform_later self }
  belongs_to :chat_room
  belongs_to :user
end
