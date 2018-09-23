class ChatRoom < ApplicationRecord
  has_many :chats, dependent: :destroy
end
