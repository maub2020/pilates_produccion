<template>
  <div class="relative" ref="dropdownRef">
    <button 
      type="button"
      @click="isOpen = !isOpen"
      class="w-full zen-input !px-2 !py-1.5 flex items-center justify-center shadow-none border border-transparent hover:border-[var(--color-sage-light)] transition-all rounded-lg h-[34px]"
      :class="currentIcon.class"
      :title="modelValue || 'Pendiente'"
    >
      <span v-html="currentIcon.icon" class="flex-shrink-0"></span>
    </button>

    <div v-if="isOpen" 
      class="absolute z-50 w-[130%] min-w-[130px] left-1/2 -translate-x-1/2 bg-white border border-gray-100 rounded-xl shadow-xl p-1.5 space-y-0.5 max-h-48 overflow-y-auto"
      :class="openUp ? 'bottom-full mb-1' : 'top-full mt-1'"
    >
      <button
        v-for="estado in estados"
        :key="estado"
        type="button"
        @click="selectOption(estado)"
        class="w-full text-left px-2 py-1.5 rounded-lg flex items-center gap-2 text-xs font-bold transition-all"
        :class="[modelValue === estado ? getIconDef(estado).class + ' border border-transparent !shadow-none' : 'hover:bg-gray-50 text-gray-700 bg-transparent border border-transparent']"
      >
        <span v-html="getIconDef(estado).icon" class="flex-shrink-0 scale-[0.85]" :class="modelValue === estado ? '' : 'text-gray-400'"></span>
        <span class="leading-none pt-0.5">{{ estado }}</span>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    required: true
  },
  estados: {
    type: Array,
    required: true
  },
  openUp: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const isOpen = ref(false)
const dropdownRef = ref(null)

const PaymentIcons = {
  "Pagado": {
    icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 8a5 5 0 00-8.5 3.5m0 3a5 5 0 008.5 3.5M6 10h5M6 14h5"></path></svg>',
    class: 'bg-green-100 text-green-700 hover:bg-green-200'
  },
  "Pagado Visa": {
    icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>',
    class: 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200'
  },
  "Pendiente": {
    icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>',
    class: 'bg-orange-50 text-orange-700 hover:bg-orange-100'
  },
  "Baja": {
    icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>',
    class: 'bg-gray-100 text-gray-500 hover:bg-gray-200'
  }
}

const getIconDef = (estado) => {
  return PaymentIcons[estado] || PaymentIcons['Pendiente']
}

const currentIcon = computed(() => getIconDef(props.modelValue))

const selectOption = (estado) => {
  emit('update:modelValue', estado)
  isOpen.value = false
}

const closeDropdown = (e) => {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target)) {
    isOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', closeDropdown)
})

onUnmounted(() => {
  document.removeEventListener('click', closeDropdown)
})
</script>
