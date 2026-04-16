import { readFileSync, writeFileSync, existsSync } from 'fs';
import { resolve } from 'path';

export default defineEventHandler(async (event) => {
    try {
        const method = getMethod(event);
        const dbPath = resolve(process.cwd(), 'server', 'db.json');

        if (method === 'GET') {
            if (!existsSync(dbPath)) {
                // Default empty state
                return {
                    configuracion: { cursos: [], profesores: [], horarios: [], estadosMes: [], añoActual: "2024" },
                    empresa: { nombre: '', nif: '', direccion: '' },
                    datosPorAño: { "2024": { alumnos: [] } }
                };
            }
            const data = readFileSync(dbPath, 'utf8');
            const db = JSON.parse(data || '{}');
            
            // Remove sensitive data
            if (db.configuracion) {
                delete db.configuracion.passwordGeneral;
                delete db.configuracion.passwordFinanciero;
            }
            
            return db;
        }

        if (method === 'POST') {
            const body = await readBody(event);
            
            // Conservar las contraseñas existentes si el cliente (web) no las envía explícitamente
            if (existsSync(dbPath)) {
                const existingDb = JSON.parse(readFileSync(dbPath, 'utf8') || '{}');
                if (body.configuracion && existingDb.configuracion) {
                    if (!body.configuracion.passwordGeneral && existingDb.configuracion.passwordGeneral) {
                        body.configuracion.passwordGeneral = existingDb.configuracion.passwordGeneral;
                    }
                    if (!body.configuracion.passwordFinanciero && existingDb.configuracion.passwordFinanciero) {
                        body.configuracion.passwordFinanciero = existingDb.configuracion.passwordFinanciero;
                    }
                }
            }

            writeFileSync(dbPath, JSON.stringify(body, null, 2));
            return { success: true };
        }
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Error desconocido';
        throw createError({
            statusCode: 500,
            statusMessage: 'Error en el servidor',
            data: {
                error: errorMessage,
                message: 'Error al procesar la solicitud. Por favor, acepte y recargue la aplicación.',
                requiresReload: true
            }
        });
    }
});
