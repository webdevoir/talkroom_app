FactoryBot.define do
  factory :chat do
    sequence(:user_id)  { |n| n }
    sequence(:chat_room_id)  { |n| n }
    sequence(:content)  { |n| "content #{n}" }
    sequence(:filename)  { |n| "filename #{n}" }
  end
end
