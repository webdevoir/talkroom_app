FactoryBot.define do
  factory :chat_room do
    sequence(:user1_id)  { n }
    sequence(:user2_id)  { n }
  end
end
