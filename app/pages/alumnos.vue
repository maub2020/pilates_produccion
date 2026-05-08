<template>
  <div class="space-y-6">
    <div v-if="pending" class="flex justify-center p-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
    </div>

    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg shadow-sm border border-red-100">
      Error al cargar los datos: {{ error }}
    </div>

    <div v-else class="space-y-6">
      <!-- Year Title & Actions -->
      <div v-if="añoActual" class="flex justify-between items-end px-2">
        <h2 class="text-3xl font-bold text-[var(--color-text)] tracking-tight leading-none">Año {{ añoActual }}</h2>

        <div class="flex items-center gap-3">
          <!-- Fecha y hora para la impresión (oculto en pantalla) -->
          <div class="hidden print:block text-right text-[10px] text-gray-500 font-mono">
            Impreso el: {{ new Date().toLocaleString('es-ES', { dateStyle: 'long', timeStyle: 'short' }) }}
          </div>

          <!-- Botones de Acción (ocultos en impresión) -->
          <div class="flex gap-2 print:hidden">
            <button @click="printTable" class="zen-button shadow-md flex-shrink-0 !py-2 !px-5 text-sm whitespace-nowrap bg-white text-[var(--color-sage-dark)] hover:bg-[var(--color-cream)] border border-[var(--color-sage-light)]">
              <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path>
              </svg>
              Imprimir
            </button>
            <button @click="openModal('add')" class="zen-button shadow-md flex-shrink-0 !py-2 !px-5 text-sm whitespace-nowrap">
              <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
              </svg>
              Añadir
            </button>
          </div>
        </div>
      </div>

      <div class="zen-card overflow-hidden !p-0 border-0 shadow-lg">
        <!-- Toolbar -->
        <div class="p-3 sm:p-4 border-b border-[var(--color-sage-light)] flex flex-col md:flex-row justify-between items-start md:items-center bg-white gap-3 lg:gap-4 print:hidden">
          <div class="flex flex-row flex-nowrap overflow-x-auto items-center gap-2 w-full pb-1 md:pb-0 custom-scrollbar">
            <div class="relative min-w-[140px] flex-shrink-0">
              <span class="absolute inset-y-0 left-0 flex items-center pl-2.5">
                <svg class="w-4 h-4 text-[var(--color-text-light)]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                </svg>
              </span>
              <input v-model="searchQuery" type="text" placeholder="Buscar..." class="zen-input w-full !pl-9 !py-1.5 text-sm !pr-3 shadow-none">
            </div>
            <select v-model="filterCurso" class="zen-input !w-auto cursor-pointer !py-1.5 !px-3 text-sm min-w-[100px] flex-shrink-0 shadow-none">
              <option value="">Cursos</option>
              <option v-for="c in db?.configuracion?.cursos" :key="c" :value="c">{{ c }}</option>
            </select>
            <select v-model="filterProfesor" class="zen-input !w-auto cursor-pointer !py-1.5 !px-3 text-sm min-w-[110px] flex-shrink-0 shadow-none">
              <option value="">Profesores</option>
              <option v-for="p in db?.configuracion?.profesores" :key="p" :value="p">{{ p }}</option>
            </select>
            <select v-model="filterHorario" class="zen-input !w-auto cursor-pointer !py-1.5 !px-3 text-sm min-w-[100px] flex-shrink-0 shadow-none">
              <option value="">Horarios</option>
              <option v-for="h in db?.configuracion?.horarios" :key="h" :value="h">{{ h }}</option>
            </select>
            <select v-model="filterMes" class="zen-input !w-auto cursor-pointer !py-1.5 !px-3 text-sm font-bold text-[var(--color-sage-dark)] border-[var(--color-sage)] bg-[var(--color-sage-light)] min-w-[100px] flex-shrink-0 shadow-none">
              <option value="">Meses</option>
              <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
            </select>
            <select v-if="filterMes" v-model="filterEstado" class="zen-input !w-auto cursor-pointer !py-1.5 !px-3 text-sm min-w-[110px] flex-shrink-0 shadow-none border-orange-200 bg-orange-50/50">
              <option value="">Cualquier estado</option>
              <option v-for="e in estadosMes" :key="e" :value="e">{{ e }}</option>
            </select>
          </div>
        </div>

        <!-- Table -->
        <div class="overflow-x-auto bg-[var(--color-cream)]/20 p-1 sm:p-2 print:overflow-visible print:bg-white print:p-0">
          <table class="w-full text-left border-separate whitespace-nowrap border-spacing-y-0.5 border-spacing-x-0 print:border-collapse print:border-spacing-0 print:text-[11px]">
            <thead>
              <tr class="text-[10px] uppercase text-[var(--color-text-light)] font-bold tracking-wider">
                <th class="py-2 px-3 rounded-tl-xl sticky left-0 bg-[var(--color-cream)] z-10 w-56 print:static print:bg-white print:border-b print:border-gray-300 print:text-black print:px-1 print:py-1">Alumno / Contacto</th>
                <th class="py-2 px-3 bg-[var(--color-cream)] print:bg-white print:border-b print:border-gray-300 print:text-black print:px-1 print:py-1">Curso</th>
                <th class="py-2 px-3 bg-[var(--color-cream)] print:bg-white print:border-b print:border-gray-300 print:text-black print:px-1 print:py-1">Horario</th>
                <th class="py-2 px-3 bg-[var(--color-cream)] print:bg-white print:border-b print:border-gray-300 print:text-black print:px-1 print:py-1">Profesor</th>
                <th class="py-2 px-3 bg-[var(--color-cream)] print:bg-white print:border-b print:border-gray-300 print:text-black print:px-1 print:py-1">Precio</th>
                <th v-for="mes in mesesMostrados" :key="mes" class="px-1 py-2 text-center bg-[var(--color-cream)] print:bg-white print:border-b print:border-gray-300 print:text-black print:px-1 print:py-1">{{ mes }}</th>
                <th class="py-2 px-3 text-right rounded-tr-xl bg-[var(--color-cream)] print:hidden">Acciones</th>
              </tr>
            </thead>
            <tbody class="text-sm">
              <tr v-for="alumno in alumnosFiltrados" :key="alumno.id" class="group bg-white hover:bg-white/90 hover:shadow-md transition-all rounded-xl relative z-0 hover:z-10 print:border-b print:border-gray-100 print:rounded-none">
                <td class="py-1.5 px-3 sticky left-0 bg-white group-hover:bg-white/90 z-10 transition-colors rounded-l-xl print:static print:px-1 print:border-b print:border-gray-200">
                  <div class="flex items-center gap-2">
                    <button @click="openModal('edit', alumno)" class="p-1.5 text-[var(--color-sage-dark)] bg-[var(--color-sage-light)]/50 opacity-0 group-hover:opacity-100 hover:bg-[var(--color-sage-light)] rounded-lg transition-all shadow-sm flex-shrink-0 print:hidden" title="Editar detalles">
                      <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path>
                      </svg>
                    </button>
                    <div class="flex flex-col">
                      <span class="font-bold text-[var(--color-text)] text-sm">{{ alumno.nombre }}</span>
                      <span class="text-[10px] text-[var(--color-text-light)] leading-none tracking-wide print:hidden">{{ alumno.telefono || 'Sin teléfono' }}</span>
                    </div>
                  </div>
                </td>
                <td class="py-1.5 px-3 text-[var(--color-text)] text-left align-middle print:px-1 print:border-b print:border-gray-200">
                  <span :class="['inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold w-fit print:px-0 print:bg-transparent print:border-0 print:text-[11px]', getColorForCurso(alumno.curso)]">
                    {{ alumno.curso }}
                  </span>
                </td>
                <td class="py-1.5 px-3 text-[var(--color-text)] text-left align-middle print:px-1 print:border-b print:border-gray-200">
                  <div class="text-[10px] font-medium text-[var(--color-text-light)] flex items-center print:text-[11px]">
                    <svg class="w-3 h-3 mr-1 print:hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    {{ alumno.horario }}
                  </div>
                </td>
                <td class="py-1.5 px-3 text-[var(--color-text)] text-left align-middle print:px-1 print:border-b print:border-gray-200">
                  <span :class="['px-2 py-1 rounded-lg flex items-center w-fit font-bold tracking-wide text-[10px] shadow-sm print:px-0 print:py-0 print:bg-transparent print:border-0 print:shadow-none print:text-[11px] print:text-gray-800', getColorForProfesor(alumno.profesor)]">
                    {{ alumno.profesor || 'Sin profesor' }}
                  </span>
                </td>
                <td class="py-1.5 px-3 font-bold text-[var(--color-text)] text-base print:px-1 print:border-b print:border-gray-200 print:text-[11px]">
                  {{ alumno.importe }}€
                </td>
                <td v-for="mes in mesesMostrados" :key="mes" class="px-0.5 py-1 text-center print:px-0 print:border-b print:border-gray-200">
                  <button @click="toggleEstado(alumno, mes)" class="w-8 h-8 rounded-lg transition-all transform hover:-translate-y-0.5 flex items-center justify-center mx-auto shadow-sm hover:shadow print:w-auto print:h-auto print:px-1 print:py-0.5 print:rounded-md print:shadow-none print:mx-auto" :title="alumno.pagos[mes]" :class="PaymentIcons[alumno.pagos[mes] || 'Pendiente']?.class">
                    <!-- Para pantalla: icono. Para imprimir: letra inicial u texto breve -->
                    <span class="scale-90 print:hidden" v-html="PaymentIcons[alumno.pagos[mes] || 'Pendiente']?.icon || '-'"></span>
                    <span class="hidden print:inline text-[9px] font-extrabold uppercase">{{ alumno.pagos[mes] === 'Pagado Visa' ? 'Visa' : (alumno.pagos[mes] || '').substring(0, 4) }}</span>
                  </button>
                </td>
                <td class="py-1.5 px-3 text-right rounded-r-xl print:hidden">
                  <div class="flex justify-end gap-1.5 transition-opacity opacity-0 group-hover:opacity-100">
                    <button @click="deleteAlumno(alumno.id)" class="p-1.5 bg-red-50 text-red-600 rounded-lg hover:bg-red-500 hover:text-white transition-all shadow-sm" title="Eliminar alumno">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="1.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="alumnosFiltrados.length === 0">
                <td :colspan="5 + mesesMostrados.length" class="p-12 text-center text-gray-500">
                  <div class="flex flex-col items-center justify-center">
                    <svg class="w-12 h-12 text-gray-300 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"></path>
                    </svg>
                    <p>No se encontraron alumnos con los filtros actuales.</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal Premium -->
    <div v-if="isModalOpen" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <!-- Background overlay -->
        <div class="fixed inset-0 bg-gray-900/40 backdrop-blur-sm transition-opacity" @click="closeModal" aria-hidden="true"></div>

        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

        <!-- Modal panel -->
        <div class="inline-block align-bottom bg-white rounded-2xl text-left shadow-2xl transform transition-all sm:my-8 sm:align-middle sm:max-w-xl w-full border border-gray-100 relative">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-8 sm:pb-6">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex-shrink-0 flex items-center justify-center h-14 w-14 rounded-full bg-[var(--color-sage-light)] sm:mx-0 sm:h-12 sm:w-12">
                <svg class="h-6 w-6 text-[var(--color-sage-dark)]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-0 sm:ml-6 sm:text-left w-full">
                <h3 class="text-2xl font-bold text-[var(--color-text)] mb-6 border-b border-[var(--color-sage-light)] pb-4" id="modal-title">
                  {{ modalMode === 'add' ? 'Añadir Nuevo Alumno' : 'Editar Alumno' }}
                </h3>

                <div class="space-y-6">
                  <!-- Name & Phone -->
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
                    <div>
                      <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Nombre Completo</label>
                      <input v-model="formData.nombre" type="text" class="zen-input w-full" placeholder="Ej. Ana Pérez">
                    </div>
                    <div>
                      <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Teléfono</label>
                      <input v-model="formData.telefono" type="text" class="zen-input w-full" placeholder="Ej. 600123456">
                    </div>
                  </div>

                  <!-- Course & Teacher -->
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
                    <div>
                      <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Curso</label>
                      <select v-model="formData.curso" class="zen-input w-full cursor-pointer">
                        <option value="">Seleccione...</option>
                        <option v-for="c in db?.configuracion?.cursos" :key="c" :value="c">{{ c }}</option>
                      </select>
                    </div>
                    <div>
                      <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Profesor</label>
                      <select v-model="formData.profesor" class="zen-input w-full cursor-pointer">
                        <option value="">Seleccione...</option>
                        <option v-for="p in db?.configuracion?.profesores" :key="p" :value="p">{{ p }}</option>
                      </select>
                    </div>
                  </div>

                  <!-- Schedule & Price -->
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
                    <div>
                      <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Horario</label>
                      <select v-model="formData.horario" class="zen-input w-full cursor-pointer">
                        <option value="">Seleccione...</option>
                        <option v-for="h in db?.configuracion?.horarios" :key="h" :value="h">{{ h }}</option>
                      </select>
                    </div>
                    <div>
                      <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Importe Mensual</label>
                      <div class="relative">
                        <input v-model.number="formData.importe" type="number" class="zen-input w-full pr-10 font-bold text-lg">
                        <div class="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none">
                          <span class="text-[var(--color-text-light)]">€</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- Quick Status Config for Add Only -->
                  <div v-if="modalMode === 'add'" class="pt-2">
                    <label class="block text-sm font-bold text-[var(--color-text-light)] mb-2 uppercase tracking-wider">Estado inicial para todos los meses</label>
                    <select v-model="formData.estadoInicial" class="zen-input w-full cursor-pointer bg-[var(--color-cream)]">
                      <option v-for="st in estadosMes" :key="st" :value="st">{{ st }}</option>
                    </select>
                  </div>

                  <!-- Edit individual months for Edit Mode -->
                  <div v-if="modalMode === 'edit'" class="pt-4 mt-6 border-t border-[var(--color-sage-light)]">
                    <h4 class="text-sm font-bold text-[var(--color-text)] mb-4 tracking-wider uppercase">Estado por meses</h4>
                    <div class="grid grid-cols-6 gap-2">
                      <div v-for="mes in meses" :key="mes" class="flex flex-col bg-[var(--color-cream)]/30 p-2 rounded-xl border border-gray-50">
                        <label class="block text-xs font-bold text-[var(--color-text-light)] mb-1.5 px-1">{{ mes }}</label>
                        <PaymentStatusSelect v-model="formData.pagos[mes]" :estados="estadosMes" :open-up="['Sep', 'Oct', 'Nov', 'Dic'].includes(mes)" />
                      </div>
                    </div>
                  </div>

                </div>
              </div>
            </div>
          </div>
          <div class="bg-[var(--color-cream)]/30 px-4 py-4 sm:px-8 sm:py-5 sm:flex sm:flex-row-reverse rounded-b-2xl border-t border-gray-100 gap-3">
            <button @click="saveModal" type="button" class="zen-button shadow-md w-full sm:w-auto">
              Guardar Cambios
            </button>
            <button @click="closeModal" type="button" class="mt-3 sm:mt-0 w-full sm:w-auto px-6 py-2.5 bg-white border border-gray-200 text-gray-600 rounded-xl hover:bg-gray-50 focus:ring-4 focus:ring-gray-100 font-bold transition-all shadow-sm">
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive, watch } from 'vue'

const { db, pending, error, refresh, saveDb: persistDb } = await useDbPage()
const meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]

const PaymentIcons = {
  "Pagado": {
    icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 8a5 5 0 00-8.5 3.5m0 3a5 5 0 008.5 3.5M6 10h5M6 14h5"></path></svg>',
    class: 'bg-green-100 text-green-700 hover:bg-green-200 border border-green-200'
  },
  "Pagado Visa": {
    icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>',
    class: 'bg-emerald-100 text-emerald-700 hover:bg-emerald-200 border border-emerald-200'
  },
  "Pendiente": {
    icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>',
    class: 'bg-orange-50 text-orange-700 hover:bg-orange-100 border border-orange-100'
  },
  "Baja": {
    icon: '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>',
    class: 'bg-gray-100 text-gray-500 hover:bg-gray-200 border border-gray-100'
  }
}

const searchQuery = ref('')
const filterCurso = ref('')
const filterProfesor = ref('')
const filterHorario = ref('')
const filterMes = ref('')
const filterEstado = ref('')

const mesesMostrados = computed(() => {
  if (filterMes.value) {
    return [filterMes.value] // Solo muestra un mes
  }
  return meses // Todos los meses
})

// Reset filterEstado when filterMes changes
watch(filterMes, (newVal) => {
  if (!newVal) filterEstado.value = ''
})

// Dinamic colors
const getColorForCurso = (curso) => {
  if (!curso) return 'bg-gray-100 text-gray-800'
  // Paleta ampliada "Zen/Premium" con tonos terrosos, naturales y suaves para evitar colisiones
  let hash = 0
  for (let i = 0; i < curso.length; i++) {
    hash = curso.charCodeAt(i) + ((hash << 5) - hash)
  }
  const colors = [
    'bg-[#E6F0EA] text-[#2D5A40] border-[#CBE0D4]', // Salvia suave
    'bg-[#F5F2E9] text-[#8C7A5B] border-[#E8DFCC]', // Crema / Arena
    'bg-[#E8F1F2] text-[#3A6B7E] border-[#C3DDE0]', // Azul plomo claro
    'bg-[#FDF6E3] text-[#A67C00] border-[#F2E4A6]', // Ocre solar
    'bg-[#ECEEE6] text-[#4F5B31] border-[#D9DED1]', // Verde Musgo
    'bg-[#F8F2F2] text-[#916262] border-[#EADCDC]', // Rosa Emolvado
    'bg-[#F2F1F8] text-[#635E8B] border-[#DCDAEC]', // Lavanda Tenue
    'bg-[#F8F4F1] text-[#A67554] border-[#EBDED3]', // Melocotón Tierra
    'bg-[#F0F2F3] text-[#556970] border-[#D8DEE0]', // Gris Pizarra
    'bg-[#F9F6F0] text-[#8B7C54] border-[#EAE2D1]', // Trigo
    'bg-[#F1F6F7] text-[#547980] border-[#D3DFE2]', // Azul Bruma
    'bg-[#F4F3F1] text-[#7A746B] border-[#E3E1DE]', // Gris Cálido
    'bg-[#F0F7F4] text-[#4A7263] border-[#D1E0D8]', // Menta Pálida
    'bg-[#F8F3F1] text-[#A66E54] border-[#ECDED7]', // Arcilla
    'bg-[#EFEFEF] text-[#4A4A4A] border-[#D1D1D1]', // Gris Piedra
  ]
  return colors[Math.abs(hash) % colors.length]
}

const getColorForProfesor = (profesor) => {
  if (!profesor) return 'bg-gray-100 text-gray-700 border-gray-200'
  let hash = 0
  for (let i = 0; i < profesor.length; i++) {
    hash = profesor.charCodeAt(i) + ((hash << 5) - hash)
  }
  const colors = [
    'bg-indigo-50 text-indigo-700 border border-indigo-200',
    'bg-teal-50 text-teal-700 border border-teal-200',
    'bg-orange-50 text-orange-700 border border-orange-200',
    'bg-fuchsia-50 text-fuchsia-700 border border-fuchsia-200',
    'bg-lime-50 text-lime-700 border border-lime-200',
    'bg-sky-50 text-sky-700 border border-sky-200',
    'bg-pink-50 text-pink-700 border border-pink-200',
    'bg-yellow-50 text-yellow-700 border border-yellow-200',
    'bg-emerald-50 text-emerald-700 border border-emerald-200',
    'bg-violet-50 text-violet-700 border border-violet-200'
  ]
  return colors[Math.abs(hash) % colors.length]
}

const estadosMes = computed(() => db.value?.configuracion?.estadosMes || ["Pagado", "Pagado Visa", "Pendiente", "Baja"])

const añoActual = computed(() => db.value?.configuracion?.añoActual || new Date().getFullYear().toString())

const getAlumnos = () => {
  return db.value?.datosPorAño?.[añoActual.value]?.alumnos || []
}

const alumnosFiltrados = computed(() => {
  const alumnos = getAlumnos()
  if (!alumnos) return []
  return alumnos
    .filter(a => {
      const matchName = a.nombre.toLowerCase().includes(searchQuery.value.toLowerCase())
      const matchCurso = filterCurso.value ? a.curso === filterCurso.value : true
      const matchProfesor = filterProfesor.value ? a.profesor === filterProfesor.value : true
      const matchHorario = filterHorario.value ? a.horario === filterHorario.value : true

      // Filtro por estado del mes (solo tiene sentido si hay un mes seleccionado)
      const matchEstado = (filterMes.value && filterEstado.value)
        ? (a.pagos[filterMes.value] || 'Pendiente') === filterEstado.value
        : true

      return matchName && matchCurso && matchProfesor && matchHorario && matchEstado
    })
    .sort((a, b) => a.nombre.localeCompare(b.nombre))
})

const saveDb = async () => {
  await persistDb(db.value)
}

const printTable = () => {
  // Disparamos la ventana de impresión del navegador
  window.print()
}

const toggleEstado = (alumno, mes) => {
  // const current = alumno.pagos[mes]
  // const list = estadosMes.value
  // const idx = list.indexOf(current)
  // if (idx === -1) {
  //   alumno.pagos[mes] = list[0]
  // } else {
  //   alumno.pagos[mes] = list[(idx + 1) % list.length]
  // }
  // saveDb()
  console.log(alumno, mes)
}

const deleteAlumno = (id) => {
  if (confirm("¿Seguro que deseas eliminar a este alumno de manera permanente en este año?")) {
    db.value.datosPorAño[añoActual.value].alumnos = getAlumnos().filter(a => a.id !== id)
    saveDb()
  }
}

// Modal State and Logic
const isModalOpen = ref(false)
const modalMode = ref('add') // 'add' or 'edit'
let editingId = null

const formData = reactive({
  nombre: '',
  telefono: '',
  curso: '',
  profesor: '',
  horario: '',
  importe: 50,
  estadoInicial: 'Pendiente',
  pagos: {}
})

const openModal = (mode, alumno = null) => {
  modalMode.value = mode
  if (mode === 'add') {
    formData.nombre = ''
    formData.telefono = ''
    formData.curso = db.value?.configuracion?.cursos[0] || ''
    formData.profesor = db.value?.configuracion?.profesores[0] || ''
    formData.horario = db.value?.configuracion?.horarios[0] || ''
    formData.importe = 50
    formData.estadoInicial = estadosMes.value[2] || 'Pendiente'
  } else if (mode === 'edit' && alumno) {
    editingId = alumno.id
    formData.nombre = alumno.nombre
    formData.telefono = alumno.telefono || ''
    formData.curso = alumno.curso || ''
    formData.profesor = alumno.profesor || ''
    formData.horario = alumno.horario || ''
    formData.importe = alumno.importe !== undefined ? alumno.importe : 50
    formData.pagos = { ...alumno.pagos }
  }
  isModalOpen.value = true
}

const closeModal = () => {
  isModalOpen.value = false
}

const saveModal = async () => {
  if (!formData.nombre.trim()) {
    alert("El nombre es obligatorio")
    return
  }

  if (modalMode.value === 'add') {
    const alumnos = getAlumnos()
    const newId = (alumnos.length > 0) ? Math.max(...alumnos.map(a => a.id)) + 1 : 1
    const newAlumno = {
      id: newId,
      nombre: formData.nombre.trim(),
      telefono: formData.telefono.trim(),
      curso: formData.curso,
      profesor: formData.profesor,
      horario: formData.horario,
      importe: Number(formData.importe) || 0,
      pagos: meses.reduce((acc, m) => ({ ...acc, [m]: formData.estadoInicial }), {})
    }
    if (!db.value.datosPorAño[añoActual.value]) {
      db.value.datosPorAño[añoActual.value] = { alumnos: [] }
    }
    db.value.datosPorAño[añoActual.value].alumnos.unshift(newAlumno)
  } else if (modalMode.value === 'edit') {
    const alumnos = getAlumnos()
    const idx = alumnos.findIndex(a => a.id === editingId)
    if (idx !== -1) {
      db.value.datosPorAño[añoActual.value].alumnos[idx].nombre = formData.nombre.trim()
      db.value.datosPorAño[añoActual.value].alumnos[idx].telefono = formData.telefono.trim()
      db.value.datosPorAño[añoActual.value].alumnos[idx].curso = formData.curso
      db.value.datosPorAño[añoActual.value].alumnos[idx].profesor = formData.profesor
      db.value.datosPorAño[añoActual.value].alumnos[idx].horario = formData.horario
      db.value.datosPorAño[añoActual.value].alumnos[idx].importe = Number(formData.importe) || 0
      db.value.datosPorAño[añoActual.value].alumnos[idx].pagos = { ...formData.pagos }
    }
  }

  await saveDb()
  await refresh()
  closeModal()
}
</script>

<style scoped>
@media print {
  @page {
    size: landscape;
    margin: 0.5cm 0.5cm 0.5cm 0.5cm;
  }

  /* Aseguramos que el fondo de los colores se imprima */
  * {
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  /* Ajustes específicos de impresión */
  .zen-card {
    box-shadow: none !important;
    margin-top: 0.5cm !important;
  }

  .overflow-x-auto {
    padding: 0.5cm !important;
  }
}
</style>
