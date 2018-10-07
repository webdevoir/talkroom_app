class AddOrderToArticleMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :article_messages, :order, :integer
  end
end
