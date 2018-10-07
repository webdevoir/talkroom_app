FactoryBot.define do
  factory :article do
    sequence(:title)  { |n| "article_title #{n}" }
    sequence(:like)  { n }
  end
end
