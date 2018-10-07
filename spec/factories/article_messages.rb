FactoryBot.define do
  factory :article_message do
    user_name { "MyString" }
    article_id { 1 }
    content { "MyText" }
    filename { "MyString" }
  end
end
