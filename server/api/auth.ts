import { readFileSync } from 'fs';
import { resolve } from 'path';

export default defineEventHandler(async (event) => {
    const body = await readBody(event);
    const password = (body.password || '').toString().trim();

    const dbPath = resolve(process.cwd(), 'server', 'db.json');

    let db;
    try {
        const data = readFileSync(dbPath, 'utf8');
        db = JSON.parse(data);
    } catch (e) {
        console.error("Error reading db.json in auth:", e);
        throw createError({
            statusCode: 500,
            statusMessage: 'Error en el servidor',
            data: {
                message: 'No se pudo leer la base de datos de autenticación. Por favor, acepte y recargue la aplicación.',
                error: e instanceof Error ? e.message : 'Error desconocido',
                requiresReload: true
            }
        });
    }

    const { passwordGeneral, passwordFinanciero } = db.configuracion || {};

    const generalStr = (passwordGeneral || '').toString().trim();
    const financieroStr = (passwordFinanciero || '').toString().trim();

    const debugInfo = `Intento: "${password}", BD General: "${generalStr}", BD Financiero: "${financieroStr}"`;
    //console.log(debugInfo);

    if (password === financieroStr && financieroStr !== '') {
        return { authenticated: true, type: 'financiero', debug: debugInfo };
    } else if (password === generalStr && generalStr !== '') {
        return { authenticated: true, type: 'general', debug: debugInfo };
    }

    return { authenticated: false, type: null, debug: debugInfo };
});
