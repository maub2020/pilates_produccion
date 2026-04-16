<template>
  <div class="space-y-6">
    <div v-if="pending" class="flex justify-center p-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
    </div>

    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg">
      Error al cargar los datos: {{ error }}
    </div>

    <template v-else>
      <!-- Hidden Toggle Button -->
      <div @click="toggleFinancials" class="fixed top-0 right-0 w-16 h-16 opacity-0 cursor-default z-50" title=""></div>

      <!-- Year & Month Title -->
      <div v-if="añoActual" class="flex flex-col items-center mb-8 relative">
        <h2
          class="text-4xl lg:text-5xl font-extrabold text-[var(--color-sage-dark)] tracking-tighter cursor-default select-none font-sans">
          {{ añoActual }}</h2>
        <div
          class="mt-2 px-6 py-2 bg-[var(--color-sage-light)] text-[var(--color-sage-dark)] rounded-full text-xs font-bold uppercase tracking-[0.3em] shadow-sm border border-[var(--color-sage)]/20">
          {{ currentMonthFull }}
        </div>
      </div>

      <!-- Stats Overview -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="zen-card hover:-translate-y-1 transition-transform duration-300">
          <div class="flex items-center text-[var(--color-text-light)] mb-3">
            <div
              class="w-8 h-8 rounded-lg bg-[var(--color-sage-light)] flex items-center justify-center mr-3 text-[var(--color-sage)]">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z">
                </path>
              </svg>
            </div>
            <span class="font-medium text-sm text-[var(--color-text-light)] uppercase tracking-wider">Total
              Estudiantes</span>
          </div>
          <div class="text-4xl font-extrabold text-[var(--color-text)] tracking-tight">{{ totalAlumnos }}</div>
        </div>

        <div class="zen-card hover:-translate-y-1 transition-transform duration-300">
          <div class="flex items-center text-emerald-600 mb-3">
            <div class="w-8 h-8 rounded-lg bg-emerald-50 flex items-center justify-center mr-3 text-emerald-500">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M15 8a5 5 0 00-8.5 3.5m0 3a5 5 0 008.5 3.5M6 10h5M6 14h5"></path>
              </svg>
            </div>
            <span class="font-medium text-sm uppercase tracking-wider">Metálico</span>
          </div>
          <div class="text-4xl font-extrabold text-[var(--color-text)] tracking-tight">
            <span v-if="isFinancieroVisible">{{ ingresosEfectivo }} €</span>
            <span v-else class="text-gray-300">***</span>
          </div>
          <div v-if="isFinancieroVisible" class="text-xs text-[var(--color-text-light)] mt-2 font-medium">Estimado: {{
            ingresosEstimados }} €</div>
        </div>

        <div class="zen-card hover:-translate-y-1 transition-transform duration-300">
          <div class="flex items-center text-emerald-600 mb-3">
            <div class="w-8 h-8 rounded-lg bg-emerald-50 flex items-center justify-center mr-3 text-emerald-500">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path>
              </svg>
            </div>
            <span class="font-medium text-sm uppercase tracking-wider">Visa</span>
          </div>
          <div class="text-4xl font-extrabold text-[var(--color-text)] tracking-tight">
            <span v-if="isFinancieroVisible">{{ ingresosVisa }} €</span>
            <span v-else class="text-gray-300">***</span>
          </div>
        </div>

        <div class="zen-card hover:-translate-y-1 transition-transform duration-300 border-l-4 border-red-400">
          <div class="flex items-center text-red-500 mb-3">
            <div class="w-8 h-8 rounded-lg bg-red-50 flex items-center justify-center mr-3 text-red-500">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
            </div>
            <span class="font-medium text-sm uppercase tracking-wider">Pendientes</span>
          </div>
          <div class="text-4xl font-extrabold text-[var(--color-text)] tracking-tight">{{ pagosPendientes }}</div>
        </div>
      </div>

      <!-- Anual Summary Table -->
      <div v-if="isFinancieroVisible" class="zen-card p-0 overflow-hidden mt-8 border-none">
        <div class="p-6 border-b border-[var(--color-sage-light)] bg-white">
          <h3 class="text-xl font-bold text-[var(--color-text)]">Resumen Anual</h3>
        </div>
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse whitespace-nowrap">
            <thead>
              <tr
                class="bg-[var(--color-cream)] border-b border-[var(--color-sage-light)] text-[10px] uppercase text-[var(--color-sage-dark)] font-extrabold tracking-[0.1em]">
                <th class="py-3 px-4 pl-6">Mes</th>
                <th class="py-3 px-4 text-emerald-600">Metálico</th>
                <th class="py-3 px-4 text-blue-600">Visa</th>
                <th class="py-3 px-4 text-[var(--color-text)]">Total Cobrado</th>
                <th class="py-3 px-4 text-red-500">Recibos Pendientes</th>
                <th class="py-3 px-4 text-gray-500">Importe Estimado</th>
                <th class="py-3 px-4 text-[var(--color-text-light)]">Alumnos Activos</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-[var(--color-sage-light)] text-sm">
              <tr v-for="row in resumenAnual" :key="row.mes"
                class="hover:bg-[var(--color-sage-light)]/30 transition-colors"
                :class="{ 'bg-[var(--color-sage-light)]/50': row.mes === currentMonth }">
                <td
                  class="py-2.5 px-4 pl-6 font-semibold text-[var(--color-text)] border-r border-[var(--color-sage-light)] flex items-center">
                  {{ row.mes }}
                  <span v-if="row.mes === currentMonth"
                    class="ml-3 text-[9px] px-2 py-0.5 bg-[var(--color-wood)] text-white rounded-md font-bold uppercase tracking-widest shadow-sm">Actual</span>
                </td>
                <td class="py-2.5 px-4 font-mono text-[var(--color-text-light)]">{{ row.efectivo }} €</td>
                <td class="py-2.5 px-4 font-mono text-[var(--color-text-light)]">{{ row.visa }} €</td>
                <td class="py-2.5 px-4 font-mono font-bold text-[var(--color-sage-dark)] bg-[var(--color-sage-light)]/20">{{
                  row.total }} €</td>
                <td class="py-2.5 px-4">
                  <span v-if="row.pendientes > 0"
                    class="inline-flex items-center px-3 py-0.5 rounded-md text-xs font-bold bg-white text-red-500 border border-red-100 shadow-sm">
                    {{ row.pendientes }}
                    <span class="ml-1 opacity-75 font-medium">({{ row.importePendientes }} €)</span>
                  </span>
                  <span v-else class="text-gray-300">-</span>
                </td>
                <td class="py-2.5 px-4 font-mono text-gray-400 italic">{{ row.importeEstimado }} €</td>
                <td class="py-2.5 px-4 font-medium text-[var(--color-text-light)]">{{ row.activos }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="zen-card">
          <div class="mb-5 border-b border-[var(--color-sage-light)] pb-4">
            <h3 class="text-xl font-bold text-[var(--color-text)]">Accesos Rápidos</h3>
          </div>
          <div class="grid grid-cols-1 gap-4">
            <NuxtLink to="/alumnos"
              class="group flex items-center p-5 rounded-xl border border-[var(--color-sage-light)] hover:border-[var(--color-sage)] hover:bg-[var(--color-cream)] hover:shadow-md transition-all">
              <div
                class="bg-white p-3 rounded-xl border border-[var(--color-sage-light)] text-[var(--color-sage)] group-hover:bg-[var(--color-sage)] group-hover:text-white transition-colors shadow-sm">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                    d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z">
                  </path>
                </svg>
              </div>
              <div class="ml-5">
                <h4 class="text-lg font-bold text-[var(--color-text)]">Ver Directorio</h4>
                <p class="text-sm text-[var(--color-text-light)]">Gestionar clases y pagos de estudiantes</p>
              </div>
            </NuxtLink>

            <NuxtLink to="/recibos"
              class="group flex items-center p-5 rounded-xl border border-[var(--color-sage-light)] hover:border-[var(--color-sage)] hover:bg-[var(--color-cream)] hover:shadow-md transition-all">
              <div
                class="bg-white p-3 rounded-xl border border-[var(--color-sage-light)] text-[var(--color-sage)] group-hover:bg-[var(--color-sage)] group-hover:text-white transition-colors shadow-sm">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                    d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z">
                  </path>
                </svg>
              </div>
              <div class="ml-5">
                <h4 class="text-lg font-bold text-[var(--color-text)]">Generar E-Recibos</h4>
                <p class="text-sm text-[var(--color-text-light)]">Crear comprobantes de pago</p>
              </div>
            </NuxtLink>
          </div>
        </div>

        <!-- Gestión de Contraseñas (Solo Financiero) -->
        <div v-if="isFinancieroVisible" class="zen-card">
          <div class="mb-5 border-b border-[var(--color-sage-light)] pb-4">
            <h3 class="text-xl font-bold text-[var(--color-text)]">Seguridad del Sistema</h3>
          </div>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Clave
                de Acceso General</label>
              <div class="relative">
                <input v-model="passwords.general" :type="showPasswordGeneral ? 'text' : 'password'" :placeholder="showPasswordGeneral ? '' : '********'"
                  class="zen-input pr-12 text-lg">
                <button @click.prevent="togglePasswordGeneral" type="button"
                  class="absolute inset-y-0 right-0 pr-4 flex items-center text-[var(--color-text-light)] hover:text-[var(--color-sage)] transition-colors">
                  <svg v-if="!showPasswordGeneral" key="closed" class="h-5 w-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-1.274 4.057-5.065 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                  <svg v-else key="open" class="h-5 w-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" />
                  </svg>
                </button>
              </div>
            </div>
            <div>
              <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Clave
                Nivel Financiero</label>
              <div class="relative">
                <input v-model="passwords.financiero" :type="showPasswordFinanciero ? 'text' : 'password'" :placeholder="showPasswordFinanciero ? '' : '********'"
                  class="zen-input pr-12 text-lg">
                <button @click.prevent="togglePasswordFinanciero" type="button"
                  class="absolute inset-y-0 right-0 pr-4 flex items-center text-[var(--color-text-light)] hover:text-[var(--color-sage)] transition-colors">
                  <svg v-if="!showPasswordFinanciero" key="closed" class="h-5 w-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-1.274 4.057-5.065 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                  <svg v-else key="open" class="h-5 w-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
          <div class="mt-8 flex justify-end">
            <button @click="savePassword" class="zen-button w-full">
              Actualizar Accesos
              <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
            </button>
          </div>
        </div>
      </div>
    </template>
  </div>

  <!-- Modal Contraseña -->
  <div v-if="showPasswordModal" class="fixed inset-0 bg-black/60 z-[100] flex items-center justify-center p-4" style="backdrop-filter: blur(4px);">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm overflow-hidden" @click.stop>
      <div class="p-6">
        <h3 class="text-xl font-bold text-[#2A3B4C] mb-4 text-center">Acceso Restringido</h3>
        <p class="text-sm text-gray-500 mb-6 text-center">Introduce la clave de acceso para continuar.</p>
        <form @submit.prevent="submitFinancialsPassword">
          <div class="mb-6">
            <input ref="passwordInputRef" v-model="modalPassword" type="password" placeholder="********" class="zen-input text-lg text-center" required>
          </div>
          <div class="flex gap-3">
            <button type="button" @click="showPasswordModal = false" class="flex-1 py-3 px-4 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-xl font-bold transition-colors">Cancelar</button>
            <button type="submit" class="flex-1 zen-button shadow-md">Acceder</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, onMounted, watch } from 'vue'

const { db, pending, error, refresh, saveDb: persistDb } = await useDbPage()

const authType = useState('authType')
const showFinancials = ref(false)
const isFinancieroVisible = computed(() => showFinancials.value || authType.value === 'financiero')

const showPasswordModal = ref(false)
const modalPassword = ref('')
const passwordInputRef = ref(null)

const toggleFinancials = () => {
  if (showFinancials.value) {
    showFinancials.value = false
  } else {
    modalPassword.value = ''
    showPasswordModal.value = true
    setTimeout(() => { if (passwordInputRef.value) passwordInputRef.value.focus() }, 50)
  }
}

const submitFinancialsPassword = async () => {
  const password = modalPassword.value
  showPasswordModal.value = false
  if (password) {
    try {
      const response = await $fetch('/api/auth', {
        method: 'POST',
        body: { password }
      })
      if (response.authenticated && response.type === 'financiero') {
        showFinancials.value = true
      } else {
        alert("Clave incorrecta")
      }
    } catch (err) {
      alert("Error de conexión al validar contraseña")
    }
  }
}

const passwords = ref({ general: '', financiero: '' })

watch(() => db.value, (newDb) => {
  if (newDb?.configuracion) {
    passwords.value.general = newDb.configuracion.passwordGeneral || ''
    passwords.value.financiero = newDb.configuracion.passwordFinanciero || ''
  }
}, { immediate: true })
const showPasswordGeneral = ref(false)
const showPasswordFinanciero = ref(false)

const togglePasswordGeneral = () => { showPasswordGeneral.value = !showPasswordGeneral.value }
const togglePasswordFinanciero = () => { showPasswordFinanciero.value = !showPasswordFinanciero.value }

const savePassword = async () => {
  if (confirm("¿Estás seguro de que deseas modificar las contraseñas de acceso al sistema?")) {
    try {
      // Create a copy of the db to send, but only updating passwords if they were provided
      const updatedDb = JSON.parse(JSON.stringify(db.value))
      if (passwords.value.general) updatedDb.configuracion.passwordGeneral = passwords.value.general
      if (passwords.value.financiero) updatedDb.configuracion.passwordFinanciero = passwords.value.financiero

      await persistDb(updatedDb)
      alert("Las contraseñas han sido actualizadas correctamente.")
    } catch (err) {
      return
    }
  } else {
    refresh()
  }
}

const meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]
const mesesCompletos = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
const currentMonth = meses[new Date().getMonth()]
const currentMonthFull = mesesCompletos[new Date().getMonth()]

const añoActual = computed(() => db.value?.configuracion?.añoActual || new Date().getFullYear().toString())

const getAlumnos = () => {
  return db.value?.datosPorAño?.[añoActual.value]?.alumnos || []
}

const totalAlumnos = computed(() => {
  const alumnos = getAlumnos()
  return alumnos.filter(a => a.pagos[currentMonth] !== 'Baja').length
})

const ingresosEstimados = computed(() => {
  const alumnos = getAlumnos()
  return alumnos
    .filter(a => a.pagos[currentMonth] !== 'Baja')
    .reduce((sum, a) => sum + (Number(a.importe) || 0), 0)
})

const ingresosEfectivo = computed(() => {
  const alumnos = getAlumnos()
  return alumnos
    .filter(a => a.pagos[currentMonth] === 'Pagado')
    .reduce((sum, a) => sum + (Number(a.importe) || 0), 0)
})

const ingresosVisa = computed(() => {
  const alumnos = getAlumnos()
  return alumnos
    .filter(a => a.pagos[currentMonth] === 'Pagado Visa')
    .reduce((sum, a) => sum + (Number(a.importe) || 0), 0)
})

const pagosPendientes = computed(() => {
  const alumnos = getAlumnos()
  return alumnos.filter(a => a.pagos[currentMonth] === 'Pendiente').length
})

const resumenAnual = computed(() => {
  const alumnos = getAlumnos()
  if (alumnos.length === 0) return []

  return meses.map(mes => {
    let efectivo = 0
    let visa = 0
    let pendientes = 0
    let importePendientes = 0
    let importeEstimado = 0
    let activos = 0

    alumnos.forEach(a => {
      const estado = a.pagos[mes]
      if (estado !== 'Baja') {
        activos++
        const imp = (Number(a.importe) || 0)
        importeEstimado += imp
        if (estado === 'Pagado') efectivo += imp
        else if (estado === 'Pagado Visa') visa += imp
        else if (estado === 'Pendiente') {
          pendientes++
          importePendientes += imp
        }
      }
    })

    return {
      mes,
      efectivo,
      visa,
      total: efectivo + visa,
      pendientes,
      importePendientes,
      importeEstimado,
      activos
    }
  })
})
</script>
