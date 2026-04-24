import consumer from "channels/consumer"

consumer.subscriptions.create("RoomChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
  }
});
