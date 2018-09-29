class Chat < ApplicationRecord
  mount_uploader :filename, ImageUploader
  after_create_commit { ChatBroadcastJob.perform_later self }
  belongs_to :chat_room
  belongs_to :user
end
