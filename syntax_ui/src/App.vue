<template>
  <CharacterCreator
    v-if="showCreator"
    :initial-data="creatorData"
  />
</template>

<script setup>
import { ref } from 'vue'
import CharacterCreator from './components/CharacterCreator.vue'

const showCreator = ref(false)
const creatorData = ref({})

window.addEventListener('message', (event) => {
  const data = event.data

  if (data?.action === 'openCreator') {
    showCreator.value = true
    creatorData.value = data.payload || {}
  }

  if (data?.action === 'closeCreator') {
    showCreator.value = false
  }
})
</script>

<style>
html, body {
  margin: 0;
  padding: 0;
  font-family: system-ui, sans-serif;
  overflow: hidden;
}
</style>
