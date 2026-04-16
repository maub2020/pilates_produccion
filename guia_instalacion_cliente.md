# Guía de Instalación para Cliente Local (Entorno Windows)

Este documento detalla cómo preparar y entregar el software al cliente final. Hemos elegido la opción de **Docker Desktop + Script `.bat`** por su robustez, pero simulando que es una aplicación de escritorio tradicional al levantar Microsoft Edge en "Modo App" y aplicando estrategias para prevenir que el cliente abra la base de datos varias veces.

## Paso 1: Configurar la Lógica de Bloqueo en Frontend (Nuxt)

Para asegurar del todo que el cliente no pueda abrir la aplicación copiando "localhost:3000" en diferentes pestañas de su navegador, añadiremos un escudo protector usando la API `BroadcastChannel`. 

Abre el archivo principal de tu aplicación Nuxt (normalmente `app.vue` en la raíz, o tu `app/pages/index.vue` si no tienes `app.vue` global). Agrega este código dentro:

```vue
<script setup>
import { onMounted, ref } from 'vue';

const estaBloqueada = ref(false);
let canal = null;

onMounted(() => {
  if (typeof window !== 'undefined') {
    canal = new BroadcastChannel('bloqueo-pestanas');
    
    // Al abrir esta pestaña, preguntamos al resto: "¿Hay alguien ahí?"
    canal.postMessage({ tipo: 'nuevo_tab' });

    canal.onmessage = (evento) => {
      // Si yo ya estaba cargado, y escucho a uno nuevo llegar, le grito "Ocupado!"
      if (evento.data.tipo === 'nuevo_tab') {
        canal.postMessage({ tipo: 'pestana_activa' });
      }
      
      // Si yo soy el nuevo, y escucho que alguien grita "Ocupado!", me autobloqueo
      if (evento.data.tipo === 'pestana_activa' && !estaBloqueada.value) {
        estaBloqueada.value = true;
      }
    };
  }
});
</script>

<template>
  <!-- Pantalla roja de alerta si intentan abrir la app por duplicado -->
  <div v-if="estaBloqueada" class="pantalla-bloqueo">
    <h2>⚠️ La aplicación ya está abierta en otra pestaña o ventana.</h2>
    <p>Por favor, cierra esta pestaña y utiliza la ventana que ya tienes abierta.</p>
    <p>Esto evita problemas de sincronización de datos de tu negocio.</p>
  </div>
  
  <!-- Tu contenido normal envuelto en el ELSE -->
  <div v-else>
    <!-- Esto representa el enrutador de tu aplicación: -->
    <NuxtPage /> 
  </div>
</template>

<style scoped>
.pantalla-bloqueo {
  height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-color: #fce4e4;
  color: #cc0000;
  text-align: center;
  padding: 3rem;
  font-family: Arial, sans-serif;
}
</style>
```


---

## Paso 2: Crear el Script de Inicio (`Pilates.bat`)

Este archivo es el "ejecutable" que el cliente usará. Lo único que debe hacer el cliente es doble clic sobre él. Este script enciende los contenedores de Docker de forma oculta en el fondo y abre Edge sin distracciones ni botones. Además, comprueba si el usuario hizo un doble clic de forma ansiosa impidiendo que se intente levantar todo dos veces.

Crea un archivo nuevo llamado `Abre_Pilates.bat` en la raíz de la carpeta que le vas a entregar y pega esto:

```bat
@echo off
:: Leer caracteres especiales como la 'ó' en Gestión.
chcp 65001 > NUL

echo =========================================
echo    INICIANDO SERVIDOR TUSALUD PILATES
echo =========================================
echo.

:: Arrancamos los contenedores silenciosamente
docker compose up -d

echo.
echo Comprobando la ventana de aplicacion...

:: Damos tiempo al servicio para que inicie y monte el puerto (3 seg)
timeout /t 3 /nobreak > NUL

:: Aqui comprobamos si Windows detecta ya una ventana abierta de Pilates (Evita doble ventana)
tasklist /V /FI "WINDOWTITLE eq Tusalud Pilates*" | find /I "Tusalud Pilates" > NUL

if "%ERRORLEVEL%"=="0" (
    echo.
    echo [AVISO] La aplicacion ya esta abierta. 
    echo Revisa tu barra inferior de tareas de Windows.
    echo.
    timeout /t 5 > NUL
    exit
) else (
    echo.
    echo Abriendo la aplicacion...
    :: Abre Edge convertido en una app independiente (Sin URLs ni iconos)
    start msedge --app="http://localhost:3000"
    exit
)
```


---

## Paso 3: Configurar Archivos de Docker (`docker-compose.yml`)

Para que la base de datos no se reinicie cada vez que Docker arranca de cero y la app arranque por sí misma en caso de que el cliente apague mal el ordenador, debes asegurarte que tus archivos Docker tengan configurada la etiqueta `restart: always` (o `unless-stopped`).

Revisa tu archivo `docker-compose.yml` base y asegúrate de que tiene una estructura similar a esto (OJO a la propiedad `restart`):

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    # Muy importante: Hace que Docker lo levante cuando inicie Windows 
    # incluso si olvidan hacer clic en el BAT.
    restart: unless-stopped 
    environment:
      - NODE_ENV=production
    volumes:
      - /app/node_modules
      # Importante mapear el db.json de forma local para que los clientes 
      # no pierdan sus datos si el contenedor docker se borra.
      # Reemplaza la ruta si no es en server/
      - ./server/db.json:/app/server/db.json 
```


---

## Pasos de Instalación Final para el Cliente (Manual)

1. En el **PC del Cliente**, asegúrate de que la virtualización en su BIOS esté activa (casi todos los modernos la tienen o WSL2).
2. Descarga e instala **Docker Desktop para Windows**. Ejecútalo al menos una vez para aceptar sus términos y condiciones y asegúrate de que el motor de Docker arranque correctamente (icono abajo a la derecha de Windows en verde).
3. Entrega una carpeta en los Documentos o Escritorio del cliente con estos archivos:
   - Toda la capeta del proyecto clonada (para tener el `Dockerfile`, carpetas, `.env`, etc.)
   - Tu `docker-compose.yml`.
   - El archivo `Abre_Pilates.bat`.
   - Opcionalmente un acceso directo de `.bat` en el escritorio del cliente y ponle un bonito icono de Pilates (Clic derecho -\> Propiedades -\> Cambiar icono).
4. El cliente a partir de ese momento solo debe hacer **Doble clic en Abre_Pilates.bat**.
