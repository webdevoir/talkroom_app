class AddColumnChats < ActiveRecord::Migration[5.2]
  def change
    add_column :chats, :user_name, :string
  end
end
