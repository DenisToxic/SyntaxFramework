<template>
  <div class="creator-backdrop">
    <div class="creator-card">
      <h1>Character Creation</h1>

      <label>
        First Name
        <input v-model="first" maxlength="16" />
      </label>

      <label>
        Last Name
        <input v-model="last" maxlength="16" />
      </label>

      <label>
        Gender
        <select v-model="gender">
          <option value="m">Male</option>
          <option value="f">Female</option>
          <option value="x">Other</option>
        </select>
      </label>

      <div class="actions">
        <button @click="submit">Create</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  initialData: {
    type: Object,
    default: () => ({})
  }
})

const first = ref('')
const last = ref('')
const gender = ref('m')

watch(
  () => props.initialData,
  (val) => {
    if (!val) return
    if (val.first_name) first.value = val.first_name
    if (val.last_name) last.value = val.last_name
    if (val.gender) gender.value = val.gender
  },
  { immediate: true }
)

const submit = () => {
  if (!first.value || !last.value) {
    console.log('[syntax_ui] Missing first or last name')
    return
  }

  fetch(`https://${GetParentResourceName()}/syntax_char:create`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: JSON.stringify({
      first_name: first.value,
      last_name: last.value,
      gender: gender.value
    })
  })
}
</script>

<style scoped>
.creator-backdrop {
  position: fixed;
  inset: 0;
  background: radial-gradient(circle at top, rgba(0,0,0,0.9), rgba(0,0,0,0.95));
  display: flex;
  align-items: center;
  justify-content: center;
}

.creator-card {
  width: 380px;
  background: rgba(15, 15, 20, 0.95);
  border-radius: 12px;
  padding: 20px 24px;
  color: #fff;
  box-shadow: 0 18px 45px rgba(0, 0, 0, 0.8);
}

h1 {
  margin: 0 0 16px;
  font-size: 22px;
  text-align: center;
}

label {
  display: block;
  margin-bottom: 12px;
  font-size: 14px;
}

input,
select {
  width: 100%;
  margin-top: 4px;
  padding: 8px 10px;
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.15);
  background: rgba(5, 5, 10, 0.9);
  color: #fff;
  outline: none;
}

input:focus,
select:focus {
  border-color: #46b8ff;
}

.actions {
  margin-top: 16px;
}

button {
  width: 100%;
  padding: 10px;
  border-radius: 6px;
  border: none;
  background: #46b8ff;
  color: #000;
  font-weight: 600;
  cursor: pointer;
}

button:hover {
  filter: brightness(1.1);
}
</style>
