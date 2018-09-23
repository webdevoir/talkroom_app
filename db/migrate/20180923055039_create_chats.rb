class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.integer :user_id
      t.integer :chat_room_id
      t.text :content
      t.string :filename

      t.timestamps
    end
  end
end
