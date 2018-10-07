FactoryBot.define do
  factory :article_message do
    sequence(:user_name)  { |n| "Person #{n}" }
    sequence(:article_id)  { n }
    sequence(:content)  { |n| "content #{n}" }
    sequence(:filename)  { |n| "filename #{n}" }
  end
end
