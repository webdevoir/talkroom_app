class CreateChatRooms < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_rooms do |t|
      t.integer :user1_id
      t.integer :user2_id

      t.timestamps
    end
  end
end
