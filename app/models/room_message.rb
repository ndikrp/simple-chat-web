class RoomMessage < ApplicationRecord
  belongs_to :room, inverse_of: :room_messages
  # Made user optional since we are using sender_name from localStorage
  belongs_to :user, optional: true

  validates :message, presence: true
  validates :sender_name, presence: true
end
