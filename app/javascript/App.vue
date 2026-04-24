<template>
  <div class="flex flex-row bg-gray-100 h-screen">
    <!-- Sidebar -->
    <div class="basis-1/3 bg-white border-r border-gray-200 flex flex-col shadow-sm z-10">
      <div
        class="flex flex-row items-center border-b border-gray-200 py-4 px-4"
      >
        <Avatar icon="pi pi-user" size="large" shape="circle" class="bg-indigo-100 text-indigo-600" />
        <div class="text-gray-900 text-lg ml-4 font-bold">Andhika</div>
        <div class="ml-auto">
          <Button
            icon="pi pi-plus-circle"
            label="Add Room"
            text
            plain
            @click="showDialog = true"
            class="text-indigo-600! text-[11px]! gap-1! px-2! py-1! hover:bg-indigo-50! font-semibold"
          />
        </div>
      </div>

      <div class="flex-1 overflow-y-auto">
        <div
          v-for="room in rooms"
          :key="room.id"
          @click="selectRoom(room)"
          :class="[
            'group flex items-center p-4 border-b border-gray-100 cursor-pointer transition-colors',
            selectedRoom?.id === room.id
              ? 'bg-indigo-50 border-l-4 border-l-indigo-600'
              : 'hover:bg-gray-50 border-l-4 border-l-transparent',
          ]"
        >
          <div class="flex-1">
            <div :class="['font-bold', selectedRoom?.id === room.id ? 'text-indigo-900' : 'text-gray-800']">{{ room.name }}</div>
            <div :class="['text-xs', selectedRoom?.id === room.id ? 'text-indigo-600/70' : 'text-gray-500']">
              Chatting as: {{ getStoredName(room.id) }}
            </div>
          </div>
          <div
            class="opacity-0 group-hover:opacity-100 flex gap-1 transition-opacity"
          >
            <Button
              icon="pi pi-pencil"
              text
              rounded
              @click.stop="openEditDialog(room)"
              class="text-gray-400! hover:text-indigo-600! p-1!"
            />
            <Button
              icon="pi pi-trash"
              text
              rounded
              @click.stop="deleteRoom(room.id)"
              class="text-gray-400! hover:text-red-600! p-1!"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Chat Container -->
    <div
      v-if="selectedRoom"
      class="basis-2/3 flex flex-col h-screen bg-gray-50"
    >
      <div
        class="flex flex-row items-center border-b border-gray-200 py-4 px-6 bg-white shadow-sm z-10"
      >
        <Avatar icon="pi pi-comments" size="large" shape="circle" class="bg-indigo-100 text-indigo-600" />
        <div class="text-gray-900 text-lg ml-4 font-bold tracking-tight">
          {{ selectedRoom.name }}
          <span class="text-sm font-normal text-gray-500"
            >(as {{ currentUserName }})</span
          >
        </div>
      </div>

      <!-- Messages Area -->
      <div 
        ref="messageContainer"
        class="flex-1 overflow-y-auto p-6 space-y-6 bg-gray-50 scroll-smooth"
      >
        <div v-if="messages.length === 0" class="text-gray-400 text-center text-sm italic pt-10">
          No messages here yet. Start the conversation!
        </div>
        <div 
          v-for="msg in messages" 
          :key="msg.id" 
          :class="['flex gap-3 max-w-[85%]', msg.sender_name === currentUserName ? 'ml-auto flex-row-reverse' : 'flex-row']"
        >
          <!-- Avatar for the Bubble -->
          <Avatar 
            :label="msg.sender_name ? msg.sender_name.charAt(0).toUpperCase() : '?'" 
            shape="circle" 
            size="normal"
            :style="{ backgroundColor: getAvatarColor(msg.sender_name || 'Anon'), color: '#fff' }"
            class="flex-shrink-0 shadow-sm border border-black/5"
          />

          <div :class="['flex flex-col', msg.sender_name === currentUserName ? 'items-end' : 'items-start']">
            <div class="text-[10px] text-gray-500 mb-1 px-1 uppercase tracking-tighter font-semibold">
              {{ msg.sender_name }} • {{ formatTime(msg.created_at) }}
            </div>
            
            <div 
              :class="['p-3 rounded-2xl shadow-sm text-sm leading-relaxed border', 
                       msg.sender_name === currentUserName 
                         ? 'bg-indigo-600 text-white rounded-tr-none border-indigo-700' 
                         : 'bg-white text-gray-800 rounded-tl-none border-gray-200']"
            >
              {{ msg.message }}
            </div>
          </div>
        </div>
      </div>

      <!-- Input Area -->
      <div class="p-4 bg-white border-t border-gray-200 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.05)] z-10">
        <form @submit.prevent="sendMessage" class="flex items-center gap-3 bg-gray-100 p-2 rounded-2xl border border-transparent focus-within:bg-white focus-within:border-indigo-300 focus-within:ring-2 focus-within:ring-indigo-100 transition-all">
          <InputText
            v-model="newMessage"
            placeholder="Type a message..."
            class="w-full bg-transparent! border-none! text-gray-900! placeholder:text-gray-500 focus:ring-0!"
          />
          <Button 
            type="submit"
            icon="pi pi-send" 
            text 
            plain 
            :disabled="!newMessage"
            class="text-indigo-600! hover:bg-indigo-50! transition-colors disabled:text-gray-400!" 
          />
        </form>
      </div>
    </div>
    <div
      v-else
      class="basis-2/3 flex items-center justify-center bg-gray-50 text-gray-400 italic"
    >
      <div class="flex flex-col items-center gap-4">
        <div class="w-16 h-16 rounded-full bg-gray-200 flex items-center justify-center">
          <i class="pi pi-comments text-2xl text-gray-400"></i>
        </div>
        Select a room to start chatting
      </div>
    </div>

    <Dialog
      v-model:visible="showDialog"
      header="Create New Room"
      :style="{ width: '25rem' }"
      modal
    >
      <div class="flex flex-col gap-4">
        <div>
          <label for="roomname" class="block font-semibold mb-1"
            >Room Name</label
          >
          <InputText
            id="roomname"
            v-model="newRoomName"
            class="w-full"
            placeholder="MHW"
          />
        </div>
        <div>
          <label for="username" class="block font-semibold mb-1"
            >Your Name</label
          >
          <InputText
            id="username"
            v-model="tempUserName"
            class="w-full"
            placeholder="e.g. Andhika"
          />
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <Button
            type="button"
            label="Cancel"
            severity="secondary"
            @click="showDialog = false"
          />
          <Button
            type="button"
            label="Create & Join"
            @click="saveRoom"
            :loading="loading"
          />
        </div>
      </div>
    </Dialog>

    <Dialog
      v-model:visible="showJoinDialog"
      header="Join Room"
      :style="{ width: '25rem' }"
      modal
    >
      <div class="flex flex-col gap-4">
        <p class="text-gray-600">
          Please enter your name to join <strong>#{{ joiningRoomName }}</strong>
        </p>
        <div>
          <label for="joinusername" class="block font-semibold mb-1 text-gray-800"
            >Your Name</label
          >
          <InputText
            id="joinusername"
            v-model="tempJoinName"
            class="w-full"
            placeholder="e.g. Andhika"
            @keyup.enter="confirmJoin"
          />
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <Button
            type="button"
            label="Cancel"
            severity="secondary"
            @click="showJoinDialog = false"
          />
          <Button type="button" label="Join Chat" @click="confirmJoin" />
        </div>
      </div>
    </Dialog>

    <Dialog
      v-model:visible="showEditDialog"
      header="Edit Room Name"
      :style="{ width: '25rem' }"
      modal
    >
      <div class="flex flex-col gap-4">
        <div>
          <label for="editroomname" class="block font-semibold mb-1"
            >New Room Name</label
          >
          <InputText
            id="editroomname"
            v-model="editingRoomName"
            class="w-full"
            placeholder="Enter new name..."
          />
        </div>
        <div class="flex justify-end gap-2 mt-4">
          <Button
            type="button"
            label="Cancel"
            severity="secondary"
            @click="showEditDialog = false"
          />
          <Button
            type="button"
            label="Save Changes"
            @click="updateRoom"
            :loading="loading"
          />
        </div>
      </div>
    </Dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue";
import { createConsumer } from "@rails/actioncable";
import Avatar from "primevue/avatar";
import InputText from "primevue/inputtext";
import Button from "primevue/button";
import Dialog from "primevue/dialog";

const consumer = createConsumer();
let roomSubscription = null;

const showDialog = ref(false);
const showJoinDialog = ref(false);
const showEditDialog = ref(false);
const joiningRoomName = ref("");
const tempJoinName = ref("");
const editingRoomId = ref(null);
const editingRoomName = ref("");
const newRoomName = ref("");
const tempUserName = ref("");
const currentUserName = ref("");
const rooms = ref([]);
const messages = ref([]);
const selectedRoom = ref(null);
const newMessage = ref("");
const loading = ref(false);
const messageContainer = ref(null);

const scrollToBottom = async () => {
  await nextTick();
  if (messageContainer.value) {
    messageContainer.value.scrollTop = messageContainer.value.scrollHeight;
  }
};

const formatTime = (dateStr) => {
  return new Date(dateStr).toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit",
  });
};

const getAvatarColor = (name) => {
  const colors = [
    "#f87171",
    "#fb923c",
    "#fbbf24",
    "#4ade80",
    "#22d3ee",
    "#818cf8",
    "#c084fc",
    "#f472b6",
  ];
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  return colors[Math.abs(hash) % colors.length];
};

// Fetch rooms on startup
onMounted(async () => {
  const response = await fetch("/rooms");
  if (response.ok) rooms.value = await response.json();
});

const getStoredName = (roomId) =>
  localStorage.getItem(`room_user_${roomId}`);

const selectRoom = async (room) => {
  const storedName = getStoredName(room.id);

  if (!storedName) {
    joiningRoomName.value = room.name;
    tempJoinName.value = "";
    showJoinDialog.value = true;
    return;
  }

  selectedRoom.value = room;
  currentUserName.value = storedName;

  // Unsubscribe from previous room
  if (roomSubscription) {
    consumer.subscriptions.remove(roomSubscription);
  }

  // Subscribe to new room
  roomSubscription = consumer.subscriptions.create(
    { channel: "RoomChannel", room_id: room.id },
    {
      received(data) {
        if (!messages.value.find((m) => m.id === data.id)) {
          messages.value.push(data);
          scrollToBottom();
        }
      },
    }
  );

  // Fetch messages for this room
  const response = await fetch(`/rooms/${room.id}/room_messages`);
  if (response.ok) {
    messages.value = await response.json();
    scrollToBottom();
  }
};

const confirmJoin = () => {
  if (!tempJoinName.value) return;

  const room = rooms.value.find((r) => r.name === joiningRoomName.value);
  if (room) {
    localStorage.setItem(`room_user_${room.id}`, tempJoinName.value);
    showJoinDialog.value = false;
    selectRoom(room);
  }
};

const sendMessage = async () => {
  if (!newMessage.value || !selectedRoom.value) return;

  try {
    const response = await fetch(`/rooms/${selectedRoom.value.id}/room_messages`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
      },
      body: JSON.stringify({ 
        room_message: { 
          message: newMessage.value,
          sender_name: currentUserName.value
        } 
      }),
    });

    if (response.ok) {
      newMessage.value = "";
    }
  } catch (error) {
    console.error("Error sending message:", error);
  }
};

const saveRoom = async () => {
  if (!newRoomName.value || !tempUserName.value) return;
  loading.value = true;

  try {
    const response = await fetch("/rooms", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
      },
      body: JSON.stringify({ room: { name: newRoomName.value } }),
    });

    if (response.ok) {
      const room = await response.json();
      rooms.value.push(room);

      localStorage.setItem(`room_user_${room.id}`, tempUserName.value);

      newRoomName.value = "";
      tempUserName.value = "";
      showDialog.value = false;
      selectRoom(room);
    }
  } catch (error) {
    console.error("Error saving room:", error);
  } finally {
    loading.value = false;
  }
};

const openEditDialog = (room) => {
  editingRoomId.value = room.id;
  editingRoomName.value = room.name;
  showEditDialog.value = true;
};

const updateRoom = async () => {
  if (!editingRoomName.value) return;
  loading.value = true;

  try {
    const response = await fetch(`/rooms/${editingRoomId.value}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
      },
      body: JSON.stringify({ room: { name: editingRoomName.value } }),
    });

    if (response.ok) {
      const updated = await response.json();
      const index = rooms.value.findIndex((r) => r.id === updated.id);
      rooms.value[index] = updated;
      if (selectedRoom.value?.id === updated.id) selectedRoom.value = updated;
      showEditDialog.value = false;
    }
  } catch (error) {
    console.error("Error updating room:", error);
  } finally {
    loading.value = false;
  }
};

const deleteRoom = async (id) => {
  if (!confirm("Are you sure you want to delete this room?")) return;

  try {
    const response = await fetch(`/rooms/${id}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
      },
    });

    if (response.ok) {
      rooms.value = rooms.value.filter((r) => r.id !== id);
      if (selectedRoom.value?.id === id) selectedRoom.value = null;
    }
  } catch (error) {
    console.error("Error deleting room:", error);
  }
};
</script>
