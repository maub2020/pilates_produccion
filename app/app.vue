<template>
  <div class="min-h-screen bg-[var(--color-cream)] text-[var(--color-text)] font-sans">
    <!-- Pantalla de Bloqueo por Pestaña Duplicada (Paso 1) -->
    <div v-if="estaBloqueada"
      class="fixed inset-0 z-[110] bg-[#fce4e4] flex items-center justify-center p-4 text-center">
      <div class="max-w-md bg-white p-10 rounded-[var(--radius-lg)] shadow-2xl border-t-4 border-[#cc0000]">
        <div class="text-[#cc0000] mb-6">
          <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z">
            </path>
          </svg>
        </div>
        <h2 class="text-2xl font-bold text-[#cc0000] mb-4">⚠️ Aplicación ya abierta</h2>
        <p class="text-[var(--color-text-light)] mb-4">La aplicación ya está abierta en otra pestaña o ventana. Por
          seguridad y para evitar problemas de sincronización, solo se permite una instancia activa.</p>
        <p class="text-sm font-semibold text-[var(--color-text)]">Por favor, cierra esta pestaña y usa la ventana
          original.</p>
      </div>
    </div>

    <div v-else-if="dbPending"
      class="fixed inset-0 z-[95] bg-[var(--color-cream)] flex items-center justify-center p-4">
      <div
        class="max-w-sm w-full bg-white p-8 rounded-[var(--radius-lg)] shadow-2xl border border-[var(--color-sage-light)] text-center">
        <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-[var(--color-sage)] mx-auto mb-4"></div>
        <p class="text-sm text-[var(--color-text-light)]">Validando datos de la aplicación...</p>
      </div>
    </div>

    <!-- Pantalla de Bloqueo por Intentos Fallidos -->
    <div v-else-if="intentos >= 3"
      class="fixed inset-0 z-[100] bg-[var(--color-text)] flex items-center justify-center p-4 text-center">
      <div class="max-w-md bg-white p-10 rounded-[var(--radius-lg)] shadow-2xl border-t-4 border-red-500">
        <div class="text-red-500 mb-6">
          <svg class="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z">
            </path>
          </svg>
        </div>
        <h1 class="text-2xl font-bold text-[var(--color-text)] mb-3">ACCESO SUSPENDIDO</h1>
        <p class="text-[var(--color-text-light)]">Se ha excedido el número de intentos. Por seguridad, contacte con el
          centro para restablecer el acceso.</p>
      </div>
    </div>

    <!-- Pantalla de Login Inicial -->
    <div v-else-if="!isAuthenticated"
      class="fixed inset-0 z-[90] bg-[var(--color-sage-light)] flex items-center justify-center p-4 dashboard-gradient">
      <div
        class="max-w-sm w-full bg-white p-10 rounded-[var(--radius-lg)] shadow-2xl transform transition-all border border-[var(--color-sage-light)]">
        <div class="flex flex-col items-center mb-8 justify-center">
          <img src="/logo.png" alt="Tusalud Pilates"
            class="h-32 w-auto mb-6 opacity-90 transition-opacity hover:opacity-100" />
          <h2 class="text-xl font-bold text-[var(--color-text)] tracking-tight">Acceso Academia</h2>
          <p class="text-[var(--color-text-light)] text-sm mt-1">Introduce la clave para continuar</p>
        </div>

        <form @submit.prevent="checkPassword" class="space-y-6">
          <div class="relative">
            <input v-model="passwordInput" type="password" placeholder="Contraseña de acceso"
              class="zen-input text-center text-lg py-4 border-2 border-[var(--color-sage-light)] focus:border-[var(--color-sage)]"
              autoFocus>
          </div>
          <p v-if="intentos > 0" class="text-red-500 text-xs text-center font-semibold bg-red-50 py-2 rounded-lg">
            Clave incorrecta. Intento {{ intentos }} de 3.
          </p>
          <button type="submit" class="zen-button w-full text-lg py-4 shadow-xl">
            Entrar al Panel
          </button>
        </form>
      </div>
    </div>

    <!-- App Content -->
    <NuxtRouteAnnouncer />
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const { pending: dbPending } = await useDbPage()
const isAuthenticated = ref(false)
const passwordInput = ref('')
const intentos = ref(0)
const authType = useState('authType', () => 'general')

// Paso 1: Lógica de Bloqueo de Pestañas con ID de Instancia
const estaBloqueada = ref(false)
let canal = null
const instanceId = Math.random().toString(36).substring(7)

onMounted(() => {
  // Lógica de autenticación existente
  if (window.sessionStorage.getItem('pilates_auth') === 'true') {
    isAuthenticated.value = true
    authType.value = window.sessionStorage.getItem('pilates_auth_type') || 'general'
  }

  // Lógica de BroadcastChannel para bloqueo (Singleton)
  if (typeof window !== 'undefined') {
    canal = new BroadcastChannel('bloqueo-pestanas')
    
    // Al abrir esta pestaña, avisamos a las demás
    setTimeout(() => {
      canal.postMessage({ tipo: 'nuevo_tab', id: instanceId })
    }, 500)

    canal.onmessage = (evento) => {
      // Ignorar mensajes que no tengan el formato esperado
      if (!evento.data || !evento.data.tipo) return

      // Si yo ya estaba cargado, y escucho a uno nuevo llegar (que no soy yo), le aviso que estoy activo
      if (evento.data.tipo === 'nuevo_tab' && evento.data.id !== instanceId) {
        canal.postMessage({ tipo: 'pestana_activa', id: instanceId })
      }
      
      // Si escucho que alguien más está activo, me autobloqueo
      if (evento.data.tipo === 'pestana_activa' && evento.data.id !== instanceId && !estaBloqueada.value) {
        console.log("Detectada otra instancia de la aplicación. Bloqueando...");
        estaBloqueada.value = true
      }
    }
  }
})


const checkPassword = async () => {
  try {
    const response = await $fetch('/api/auth', {
      method: 'POST',
      body: { password: passwordInput.value }
    })

    if (response.authenticated) {
      isAuthenticated.value = true
      authType.value = response.type
      window.sessionStorage.setItem('pilates_auth', 'true')
      window.sessionStorage.setItem('pilates_auth_type', response.type)
    } else {
      intentos.value++
      if (response.debug) {
        alert("Fallo de clave. " + response.debug)
      }
      passwordInput.value = ''
      if (intentos.value >= 3) {
        window.sessionStorage.removeItem('pilates_auth')
        window.sessionStorage.removeItem('pilates_auth_type')
      }
    }
  } catch (err) {
    alert("Error de conexión al validar contraseña")
  }
}
</script>
