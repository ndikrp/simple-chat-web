class ChangeUserIdToOptionalInRoomMessages < ActiveRecord::Migration[8.1]
  def change
    change_column_null :room_messages, :user_id, true
  end
end
