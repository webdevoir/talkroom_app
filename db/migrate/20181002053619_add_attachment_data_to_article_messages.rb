class AddAttachmentDataToArticleMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :article_messages, :attachment_data, :text
  end
end
