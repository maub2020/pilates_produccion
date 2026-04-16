<template>
  <div class="flex h-screen overflow-hidden bg-[var(--color-cream)] font-sans">
    <!-- Sidebar Overlay (Mobile) -->
    <div v-if="isSidebarOpen" @click="isSidebarOpen = false" class="fixed inset-0 bg-[var(--color-text)]/40 backdrop-blur-sm z-40 lg:hidden transition-opacity"></div>

    <!-- Sidebar -->
    <aside :class="[
      'fixed inset-y-0 left-0 z-50 w-72 bg-white flex flex-col transform transition-transform duration-500 ease-in-out lg:relative lg:translate-x-0 lg:w-72 border-r border-[var(--color-sage-light)] shadow-2xl lg:shadow-none print:hidden',
      isSidebarOpen ? 'translate-x-0' : '-translate-x-full'
    ]">
      <div class="px-8 py-10 flex items-center justify-between">
        <img src="/logo.png" alt="Tusalud Pilates" class="h-20 w-auto transition-transform hover:scale-105 duration-300" />
        <button @click="isSidebarOpen = false" class="lg:hidden p-2 text-[var(--color-text-light)] hover:text-[var(--color-sage)]">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>

      <nav class="flex-1 px-4 space-y-2 overflow-y-auto custom-scrollbar">
        <NuxtLink v-for="item in navItems" :key="item.path" :to="item.path" @click="isSidebarOpen = false" class="flex items-center space-x-3 px-6 py-4 rounded-2xl text-[var(--color-text-light)] hover:bg-[var(--color-sage-light)] hover:text-[var(--color-sage)] transition-all duration-300 group" active-class="bg-[var(--color-sage-light)] text-[var(--color-sage-dark)] font-bold shadow-sm">
          <div class="w-10 h-10 rounded-xl bg-gray-50 flex items-center justify-center group-hover:bg-white border border-transparent group-hover:border-[var(--color-sage-light)] transition-all duration-300" v-html="item.icon">
          </div>
          <span class="text-sm tracking-tight">{{ item.label }}</span>
        </NuxtLink>
      </nav>

      <div class="p-8 space-y-6">
        <div class="bg-gray-50/50 p-4 rounded-2xl border border-gray-100">
          <p class="text-[9px] uppercase tracking-widest text-gray-400 font-bold text-center mb-4">Desarrollado por</p>
          <a href="https://www.abakan.es" target="_blank" class="flex flex-col items-center group transition-all">
            <img src="/abakan-logo.png" alt="Abakan Sistemas" class="h-8 w-auto opacity-90 group-hover:opacity-100 transition-all drop-shadow-[0_1px_2px_rgba(0,0,0,0.5)]" />
          </a>
        </div>
        <div class="text-[10px] text-[var(--color-text-light)] text-center opacity-50">
          Pilates Dashboard v2.0 © {{ new Date().getFullYear() }}
        </div>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col h-screen overflow-hidden w-full dashboard-gradient print:h-auto print:overflow-visible">
      <!-- Top header -->
      <header class="h-20 flex items-center justify-between px-6 lg:px-12 shrink-0 z-30 print:hidden">
        <div class="flex items-center space-x-4">
          <button @click="isSidebarOpen = true" class="lg:hidden p-3 text-[var(--color-text)] bg-white shadow-sm rounded-xl hover:bg-[var(--color-sage-light)] transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
          </button>
          <div>
            <h2 class="text-xl lg:text-2xl font-extrabold text-[var(--color-text)] tracking-tight">{{ pageTitle }}</h2>
            <p class="text-xs text-[var(--color-text-light)] font-medium"></p>
          </div>
        </div>

        <div class="flex items-center space-x-4">
          <!-- Perfil / Notificaciones (Opcional) -->
          <div class="w-10 h-10 rounded-full bg-white border border-[var(--color-sage-light)] flex items-center justify-center text-[var(--color-sage)] shadow-sm">
            <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path>
            </svg>
          </div>
        </div>
      </header>

      <!-- Page content -->
      <div class="flex-1 overflow-auto p-6 lg:p-12 custom-scrollbar print:overflow-visible print:p-0">
        <slot />
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const isSidebarOpen = ref(false)

const pageTitle = computed(() => {
  const path = route.path
  if (path === '/') return 'Panel Principal'
  if (path.startsWith('/alumnos')) return 'Gestión de Alumnos'
  if (path.startsWith('/configuracion')) return 'Configuración'
  if (path.startsWith('/recibos')) return 'Generador de Recibos'
  return 'Gestión'
})

// SVG codes for icons updated to be more elegant
const icons = {
  dashboard: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path></svg>',
  alumnos: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>',
  recibos: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>',
  config: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>'
}

const navItems = [
  { path: '/', label: 'Panel', icon: icons.dashboard },
  { path: '/alumnos', label: 'Gestión de Alumnos', icon: icons.alumnos },
  { path: '/recibos', label: 'Generador de Recibos', icon: icons.recibos },
  { path: '/configuracion', label: 'Configuración', icon: icons.config }
]
</script>

<style>
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
}

.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  background: var(--color-sage-light);
  border-radius: 10px;
}

.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: var(--color-sage);
}
</style>
