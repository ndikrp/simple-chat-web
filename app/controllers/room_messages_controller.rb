class RoomMessagesController < ApplicationController
  def index
    @room = Room.find(params[:room_id])
    render json: @room.room_messages.order(created_at: :asc)
  end

  def create
    @room = Room.find(params[:room_id])
    @message = @room.room_messages.create(message_params)

    if @message.save
      ActionCable.server.broadcast("room_channel_#{params[:room_id]}", @message)
      render json: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:room_message).permit(:message, :sender_name)
  end
end
