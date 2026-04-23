class AddSender < ActiveRecord::Migration[8.1]
  def change
    add_column :room_messages, :sender_name, :string
  end
end
