FactoryBot.define do
  factory :chat_room do
    sequence(:user1_id)  { |n| n }
    sequence(:user2_id)  { |n| n }
  end
end
