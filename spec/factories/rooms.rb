FactoryBot.define do
  factory :room do
    sequence(:name)  { |n| "title #{n}" }
  end
end
