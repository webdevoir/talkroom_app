FactoryBot.define do
  factory :chat do
    user_id { 1 }
    chat_room_id { 1 }
    content { "MyText" }
    filename { "MyString" }
  end
end
