<template>
  <div class="space-y-6">
    <div v-if="pending" class="flex justify-center p-12">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
    </div>
    
    <div v-else-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg">
      Error al cargar los datos: {{ error }}
    </div>
    
    <div v-else class="grid grid-cols-1 lg:grid-cols-2 gap-8 print:block">
      <!-- Selector (No print) -->
      <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 print:hidden">
        <h3 class="text-lg font-semibold text-gray-800 mb-4">Generar Recibo/Factura</h3>
        
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Seleccionar Alumno</label>
            <select v-model="selectedAlumnoId" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
              <option :value="null">-- Seleccione --</option>
              <option v-for="a in alumnosAño" :key="a.id" :value="a.id">{{ a.nombre }}</option>
            </select>
          </div>
          
          <div v-if="selectedAlumno">
            <label class="block text-sm font-medium text-gray-700 mb-1">Meses a facturar (con retardo Ctrl+Click para varios)</label>
            <select v-model="selectedMeses" multiple class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 h-32">
              <option v-for="mes in meses" :key="mes" :value="mes">{{ mes }} ({{ selectedAlumno.pagos[mes] }})</option>
            </select>
          </div>
          
          <div v-if="selectedAlumno" class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Tipo de Documento</label>
              <select v-model="docType" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500">
                <option value="RECIBO">Recibo</option>
                <option value="FACTURA">Factura</option>
              </select>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nº Documento</label>
              <input v-model="docNumber" type="text" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500" placeholder="Ej: 2024-001">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Fecha</label>
              <input v-model="docDate" type="date" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500">
            </div>
          </div>
          
          <div v-if="selectedAlumno" class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Concepto Extra (Opcional)</label>
              <input v-model="docComment" type="text" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500" placeholder="Ej: Matrícula, fianza...">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Importe Concepto</label>
              <div class="relative">
                <input v-model.number="docExtraAmount" type="number" class="w-full px-4 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-indigo-500 pr-10" placeholder="0">
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none text-gray-400">€</div>
              </div>
            </div>
          </div>
          
          <div v-if="selectedAlumno" class="pt-4 border-t border-gray-100 flex justify-end">
            <button @click="printReceipt" class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 font-medium transition-colors">
              Imprimir Recibo
            </button>
          </div>
        </div>
      </div>

      <!-- Receipt Preview (Printable) -->
      <div v-if="selectedAlumno" class="flex flex-col space-y-4">
        <!-- Print Action Button directly above the receipt -->
        <div class="flex justify-end print:hidden">
          <button @click="printReceipt" class="flex items-center px-5 py-2.5 bg-gray-900 text-white rounded-xl hover:bg-gray-800 focus:ring-4 focus:ring-gray-200 font-medium transition-all shadow-lg shadow-gray-200">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path></svg>
            Imprimir Recibo
          </button>
        </div>
        
        <div class="bg-white p-12 w-full max-w-2xl mx-auto shadow-sm border border-gray-100 flex flex-col min-h-[500px]">
        <div class="flex justify-between items-start mb-12 border-b-2 border-gray-800 pb-8">
          <div>
            <h1 class="text-3xl font-bold text-gray-900 tracking-tight">{{ db.empresa.nombre }}</h1>
            <div class="mt-2 text-sm text-gray-500">
              <p>NIF: {{ db.empresa.nif }}</p>
              <p>{{ db.empresa.direccion }}</p>
            </div>
          </div>
          <div class="text-right">
            <p class="text-2xl font-light text-gray-400">{{ docType }}</p>
            <p class="font-medium mt-1">Nº: {{ docNumber }}</p>
            <p class="text-sm text-gray-500">Fecha: {{ formattedDate }}</p>
          </div>
        </div>

        <div class="mb-12">
          <p class="text-sm text-gray-500 uppercase tracking-wider mb-1">Recibí de:</p>
          <p class="text-xl font-medium text-gray-900">{{ selectedAlumno.nombre }}</p>
          <p class="text-gray-600">Teléfono: {{ selectedAlumno.telefono }}</p>
        </div>

        <table class="w-full mb-12">
          <thead>
            <tr class="border-b border-gray-200">
              <th class="text-left py-3 font-medium text-gray-500">Concepto</th>
              <th class="text-right py-3 font-medium text-gray-500">Importe</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="(docComment && docComment.trim() !== '') || docExtraAmount > 0" class="border-b border-gray-100 bg-gray-50/30">
              <td class="py-4">
                <span class="font-medium text-gray-900">{{ docComment || 'Concepto Extra' }}</span>
              </td>
              <td class="py-4 text-right align-top">{{ docExtraAmount > 0 ? docExtraAmount + ' €' : '-' }}</td>
            </tr>
            <tr v-for="mes in displayMeses" :key="mes" class="border-b border-gray-100">
              <td class="py-4">
                <span class="font-medium text-gray-900">Mensualidad {{ mes }}</span>
                <span class="block text-sm text-gray-500">{{ selectedAlumno.curso }}</span>
              </td>
              <td class="py-4 text-right align-top">{{ selectedAlumno.importe }} €</td>
            </tr>
            <tr v-if="displayMeses.length === 0 && !docExtraAmount" class="border-b border-gray-100">
              <td colspan="2" class="py-4 text-center text-gray-400 italic">No hay meses ni conceptos seleccionados</td>
            </tr>
          </tbody>
          <tfoot v-if="displayMeses.length > 0 || docExtraAmount > 0">
            <tr>
              <th class="text-right py-6 text-lg font-medium text-gray-800">Total a pagar:</th>
              <th class="text-right py-6 text-2xl font-bold text-indigo-600">
                {{ totalImporte }} €
                <span class="block text-xs text-gray-400 font-normal mt-1">(IVA INCLUIDO)</span>
              </th>
            </tr>
          </tfoot>
        </table>

        <div class="mt-auto pt-16 border-t border-gray-200 grid grid-cols-2 gap-8 text-center">
          <div>
            <div class="h-20 border-b border-gray-300 mx-8"></div>
            <p class="mt-2 text-sm text-gray-500">Firma Centro</p>
          </div>
          <div>
            <div class="h-20 border-b border-gray-300 mx-8"></div>
            <p class="mt-2 text-sm text-gray-500">La firma del Alumno</p>
          </div>
        </div>
      </div>
    </div>
    <div v-else class="flex items-center justify-center text-gray-400 print:hidden border-2 border-dashed border-gray-200 rounded-xl">
      Selecciona un alumno para ver el recibo
    </div>
  </div>
</div>
</template>

<script setup>
import { ref, computed } from 'vue'

const { db, pending, error } = await useDbPage()
const meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]

const selectedAlumnoId = ref(null)
const selectedMeses = ref([])

const docType = ref('RECIBO')
const docNumber = ref('')
const docDate = ref(new Date().toISOString().split('T')[0])
const docComment = ref('')
const docExtraAmount = ref(0)

const formattedDate = computed(() => {
  if (!docDate.value) return new Date().toLocaleDateString()
  const [year, month, day] = docDate.value.split('-')
  return `${day}/${month}/${year}`
})

// Initialize docNumber on mount and save to localStorage on change
import { onMounted, watch } from 'vue'

onMounted(() => {
  const savedNumber = localStorage.getItem('pilates_last_doc_number')
  if (savedNumber) {
    docNumber.value = savedNumber
  } else {
    docNumber.value = `${new Date().getFullYear()}-001`
  }
})

watch(docNumber, (newVal) => {
  localStorage.setItem('pilates_last_doc_number', newVal)
})

const añoActual = computed(() => db.value?.configuracion?.añoActual || new Date().getFullYear().toString())

const alumnosAño = computed(() => {
  return db.value?.datosPorAño?.[añoActual.value]?.alumnos || []
})

const selectedAlumno = computed(() => {
  if (!alumnosAño.value || !selectedAlumnoId.value) return null
  return alumnosAño.value.find(a => a.id === selectedAlumnoId.value)
})

const displayMeses = computed(() => {
  return selectedMeses.value
})

const totalImporte = computed(() => {
  if (!selectedAlumno.value) return 0
  const totalMeses = Number(selectedAlumno.value.importe) * displayMeses.value.length
  const extra = Number(docExtraAmount.value || 0)
  return totalMeses + extra
})

const printReceipt = () => {
  window.print()
}
</script>

<style>
@media print {
  @page {
    margin: 0;
    size: A4 portrait;
  }
  body {
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
    background: white;
  }
  /* Hide nuxt layout shell entirely except main slot */
  aside, header { display: none !important; }
  main { height: auto !important; padding: 0 !important; overflow: visible !important; }
  .print\:hidden { display: none !important; }
}
</style>
