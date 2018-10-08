FactoryBot.define do
  factory :message do
    sequence(:user_id)  { |n| n }
    sequence(:room_id)  { |n| n }
    sequence(:content)  { |n| "content #{n}" }
    sequence(:filename)  { |n| "filename #{n}" }
  end
end
