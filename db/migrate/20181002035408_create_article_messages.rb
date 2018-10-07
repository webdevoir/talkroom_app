class CreateArticleMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :article_messages do |t|
      t.string :user_name
      t.integer :article_id
      t.text :content
      t.string :filename

      t.timestamps
    end
  end
end
