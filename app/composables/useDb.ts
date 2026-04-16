const DEFAULT_DB_ERROR_MESSAGE = 'Error al procesar la base de datos. Pulse aceptar para recargar la aplicación.'

function normalizeDbError(error: any) {
  const responseData = error?.data
  const payload = responseData?.data ?? responseData ?? {}

  return {
    statusCode: error?.statusCode || responseData?.statusCode || 500,
    statusMessage: responseData?.statusMessage || error?.statusMessage || 'Error en la base de datos',
    message: payload.message || DEFAULT_DB_ERROR_MESSAGE,
    details: payload.error || error?.message || 'Error desconocido',
    requiresReload: payload.requiresReload ?? true
  }
}

function raiseDbError(error: any): never {
  const normalized = normalizeDbError(error)
  const nuxtError = createError({
    statusCode: normalized.statusCode,
    statusMessage: normalized.statusMessage,
    fatal: true,
    data: {
      message: normalized.message,
      error: normalized.details,
      requiresReload: normalized.requiresReload
    }
  })

  showError(nuxtError)
  throw nuxtError
}

export function useDbApi() {
  const db = useState('db:data', () => null)
  const pending = useState('db:pending', () => false)
  const error = computed(() => null)

  const loadDb = async (force = false) => {
    if (!force && db.value) {
      return db.value
    }

    pending.value = true

    try {
      const data = await $fetch('/api/db')
      db.value = data
      return data
    } catch (fetchError) {
      raiseDbError(fetchError)
    } finally {
      pending.value = false
    }
  }

  const refresh = async () => {
    return await loadDb(true)
  }

  const saveDb = async (nextDb = db.value) => {
    pending.value = true

    try {
      await $fetch('/api/db', {
        method: 'POST',
        body: nextDb
      })
      db.value = nextDb
      return db.value
    } catch (saveError) {
      raiseDbError(saveError)
    } finally {
      pending.value = false
    }
  }

  return {
    db,
    pending,
    error,
    loadDb,
    refresh,
    saveDb
  }
}

export async function useDbPage() {
  const api = useDbApi()
  await api.loadDb()
  return api
}