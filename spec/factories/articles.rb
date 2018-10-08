FactoryBot.define do
  factory :article do
    sequence(:title)  { |n| "article_title #{n}" }
    sequence(:like)  { 0 }
  end
end
