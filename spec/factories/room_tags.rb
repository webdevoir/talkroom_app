FactoryBot.define do
  factory :room_tag do
    sequence(:room_id)  { n }
    sequence(:name)  { |n| "name #{n}" }
  end
end
