<template>
  <div class="space-y-6 max-w-6xl w-full mx-auto">
    <div v-if="pending" class="flex justify-center p-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
    </div>

    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg">
      Error al cargar los datos: {{ error }}
    </div>

    <template v-else>
      <div class="zen-card">
        <h3 class="text-xl font-bold text-[var(--color-text)] mb-5 border-b border-[var(--color-sage-light)] pb-4">Datos de la Empresa</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Nombre Comercial</label>
            <input v-model="db.empresa.nombre" type="text" class="zen-input text-lg" @change="saveDb">
          </div>
          <div>
            <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">NIF / CIF</label>
            <input v-model="db.empresa.nif" type="text" class="zen-input text-lg" @change="saveDb">
          </div>
        </div>
        <div class="mt-6">
          <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Dirección</label>
          <input v-model="db.empresa.direccion" type="text" class="zen-input text-lg w-full" @change="saveDb">
        </div>
      </div>


      <!-- Gestión de Contraseñas (Solo Financiero) -->
      <div v-if="isFinanciero" class="zen-card">
        <h3 class="text-xl font-bold text-[var(--color-text)] mb-5 border-b border-[var(--color-sage-light)] pb-4">Gestión de Contraseñas</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Contraseña General</label>
            <div class="relative">
              <input v-model="passwords.general" :type="showPasswordGeneral ? 'text' : 'password'" :placeholder="showPasswordGeneral ? '' : '********'" class="zen-input pr-12 text-lg">
              <button @click.prevent="togglePasswordGeneral" type="button" class="absolute inset-y-0 right-0 pr-4 flex items-center text-[var(--color-text-light)] hover:text-[var(--color-sage)] transition-colors">
                <svg v-if="!showPasswordGeneral" key="closed" class="h-5 w-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-1.274 4.057-5.065 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                <svg v-else key="open" class="h-5 w-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" /></svg>
              </button>
            </div>
          </div>
          <div>
            <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Contraseña Financiera</label>
            <div class="relative">
              <input v-model="passwords.financiero" :type="showPasswordFinanciero ? 'text' : 'password'" :placeholder="showPasswordFinanciero ? '' : '********'" class="zen-input pr-12 text-lg">
              <button @click.prevent="togglePasswordFinanciero" type="button" class="absolute inset-y-0 right-0 pr-4 flex items-center text-[var(--color-text-light)] hover:text-[var(--color-sage)] transition-colors">
                <svg v-if="!showPasswordFinanciero" key="closed" class="h-5 w-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-1.274 4.057-5.065 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                <svg v-else key="open" class="h-5 w-5 pointer-events-none" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l18 18" /></svg>
              </button>
            </div>
          </div>
        </div>
        <div class="mt-8 flex justify-end">
          <button @click="savePassword" class="zen-button shadow-md">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            Guardar Contraseñas
          </button>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 pb-12">
        <!-- Cursos -->
        <div class="zen-card flex flex-col h-96">
          <h3 class="text-xl font-bold text-[var(--color-text)] mb-4 border-b border-[var(--color-sage-light)] pb-2">Cursos</h3>
          <ul class="flex-1 overflow-auto space-y-2 mb-4 custom-scrollbar pr-2">
            <li v-for="(curso, idx) in db.configuracion.cursos" :key="idx" class="flex justify-between items-center p-3 hover:bg-[var(--color-sage-light)] rounded-xl border border-transparent transition-colors shadow-sm">
              <span class="text-[var(--color-text)] font-medium">{{ curso }}</span>
              <button @click="removeItem('cursos', idx)" class="text-[var(--color-text-light)] hover:text-red-500 p-1 transition-colors">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </li>
          </ul>
          <div class="flex mt-auto pt-4 border-t border-[var(--color-sage-light)]">
            <input v-model="newCurso" type="text" placeholder="Nuevo curso..." class="zen-input rounded-r-none border-r-0" @keyup.enter="addItem('cursos', newCurso); newCurso = ''">
            <button @click="addItem('cursos', newCurso); newCurso = ''" class="zen-button rounded-l-none border border-[var(--color-sage)] shadow-none">Añadir</button>
          </div>
        </div>

        <!-- Profesores -->
        <div class="zen-card flex flex-col h-96">
          <h3 class="text-xl font-bold text-[var(--color-text)] mb-4 border-b border-[var(--color-sage-light)] pb-2">Profesores</h3>
          <ul class="flex-1 overflow-auto space-y-2 mb-4 custom-scrollbar pr-2">
            <li v-for="(prof, idx) in db.configuracion.profesores" :key="idx" class="flex justify-between items-center p-3 hover:bg-[var(--color-sage-light)] rounded-xl border border-transparent transition-colors shadow-sm">
              <span class="text-[var(--color-text)] font-medium">{{ prof }}</span>
              <button @click="removeItem('profesores', idx)" class="text-[var(--color-text-light)] hover:text-red-500 p-1 transition-colors">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </li>
          </ul>
          <div class="flex mt-auto pt-4 border-t border-[var(--color-sage-light)]">
            <input v-model="newProf" type="text" placeholder="Nuevo profesor..." class="zen-input rounded-r-none border-r-0" @keyup.enter="addItem('profesores', newProf); newProf = ''">
            <button @click="addItem('profesores', newProf); newProf = ''" class="zen-button rounded-l-none border border-[var(--color-sage)] shadow-none">Añadir</button>
          </div>
        </div>

        <!-- Horarios -->
        <div class="zen-card flex flex-col h-96">
          <h3 class="text-xl font-bold text-[var(--color-text)] mb-4 border-b border-[var(--color-sage-light)] pb-2">Horarios</h3>
          <ul class="flex-1 overflow-auto space-y-2 mb-4 custom-scrollbar pr-2">
            <li v-for="(horario, idx) in db.configuracion.horarios" :key="idx" class="flex justify-between items-center p-3 hover:bg-[var(--color-sage-light)] rounded-xl border border-transparent transition-colors shadow-sm">
              <span class="text-[var(--color-text)] font-mono font-bold">{{ horario }}</span>
              <button @click="removeItem('horarios', idx)" class="text-[var(--color-text-light)] hover:text-red-500 p-1 transition-colors">
                <svg class="w-5 h-5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </li>
          </ul>
          <div class="flex mt-auto pt-4 border-t border-[var(--color-sage-light)]">
            <input v-model="newHorario" type="text" placeholder="Ej: 11:00 - 12:00" class="zen-input rounded-r-none border-r-0 font-mono" @keyup.enter="addItem('horarios', newHorario); newHorario = ''">
            <button @click="addItem('horarios', newHorario); newHorario = ''" class="zen-button rounded-l-none border border-[var(--color-sage)] shadow-none">Añadir</button>
          </div>
        </div>
      </div>

      <!-- Year Management -->
      <div class="zen-card pb-8">
        <h3 class="text-xl font-bold text-[var(--color-text)] mb-5 border-b border-[var(--color-sage-light)] pb-4">Gestión de Año de Trabajo</h3>
        <div class="flex flex-col sm:flex-row items-start sm:items-end gap-6">
          <div class="w-full sm:flex-1">
            <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Año Activo</label>
            <select v-model="db.configuracion.añoActual" @change="saveDb" class="zen-input font-bold text-[var(--color-sage-dark)] cursor-pointer text-lg">
              <option v-for="year in availableYears" :key="year" :value="year">{{ year }}</option>
            </select>
            <p class="text-xs text-[var(--color-text-light)] mt-2 italic">Este es el año que se muestra en toda la aplicación.</p>
          </div>
          <button @click="createNewYear" class="zen-button w-full sm:w-auto shadow-md">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
            </svg>
            Crear Nuevo Año
          </button>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const { db, pending, error, refresh, saveDb: persistDb } = await useDbPage()

const authType = useState('authType')
const isFinanciero = computed(() => authType.value === 'financiero')

const newCurso = ref('')
const newProf = ref('')
const newHorario = ref('')

const availableYears = computed(() => {
  if (!db.value?.datosPorAño) return [new Date().getFullYear().toString()]
  return Object.keys(db.value.datosPorAño).sort().reverse()
})

const createNewYear = async () => {
  const currentYear = db.value?.configuracion?.añoActual
  if (!currentYear) return

  const inputYear = prompt("Introduce el nuevo año a crear (por ejemplo, 2025):")
  if (!inputYear) return

  if (db.value.datosPorAño[inputYear]) {
    alert("Ese año ya existe en la base de datos.")
    return
  }

  if (confirm(`¿Estás seguro de crear el año ${inputYear}? \n\nSe copiarán todos los alumnos del año ${currentYear} que NO estén de baja en Diciembre. A los alumnos que se pasen, se les pondrán todos sus meses como 'Pendiente'.`)) {
    const oldStudents = db.value.datosPorAño[currentYear]?.alumnos || []

    // Filter out students whose payment status in December was Baja
    const newStudents = oldStudents
      .filter(a => a.pagos["Dic"] !== 'Baja')
      .map(a => {
        const resetPagos = { ...a.pagos }
        for (const month in resetPagos) {
          resetPagos[month] = 'Pendiente'
        }
        return {
          ...a,
          pagos: resetPagos
        }
      })

    db.value.datosPorAño[inputYear] = { alumnos: newStudents }
    db.value.configuracion.añoActual = inputYear
    await saveDb()
    alert(`Año ${inputYear} creado correctamente. Se han migrado ${newStudents.length} alumnos desde ${currentYear}.`)
  }
}

const saveDb = async () => {
  await persistDb(db.value)
  await refresh()
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
    const updatedDb = JSON.parse(JSON.stringify(db.value))
    if (passwords.value.general) updatedDb.configuracion.passwordGeneral = passwords.value.general
    if (passwords.value.financiero) updatedDb.configuracion.passwordFinanciero = passwords.value.financiero
    
    try {
      await persistDb(updatedDb)
      await refresh()
      alert("Las contraseñas han sido actualizadas correctamente.")
    } catch (err) {
      return
    }
  } else {
    refresh()
  }
}

const addItem = async (listName, val) => {
  if (!val.trim()) return
  db.value.configuracion[listName].push(val.trim())
  await saveDb()
}

const removeItem = async (listName, idx) => {
  if (confirm("¿Estás seguro de eliminar este elemento?")) {
    db.value.configuracion[listName].splice(idx, 1)
    await saveDb()
  }
}
</script>
