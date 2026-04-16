@echo off
:: Desactivamos el eco para una terminal limpia
echo =========================================
echo    INICIANDO SERVIDOR TUSALUD PILATES
echo =========================================
echo.

:: Cambio respecto a la version anterior:
:: - Antes se hacia un arranque silencioso con `docker compose up -d > NUL 2>&1`.
:: - Para soporte al cliente conviene mantener salida visible cuando algo falla.
:: - Asi, si Docker Desktop no esta arrancado o falta algun archivo, el usuario
::   ve un mensaje claro en lugar de una ventana que se cierra sin contexto.

:: Version anterior, mantenida como referencia:
:: docker compose up -d > NUL 2>&1

:: Validacion minima: la base de datos local debe existir porque el compose monta
:: C:/data/db.json dentro del contenedor.
if not exist "C:\data\db.json" (
	echo ERROR: No existe C:\data\db.json
	echo.
	echo Antes de arrancar la aplicacion, copia el archivo db.json del proyecto a C:\data\db.json
	echo.
	pause
	exit /b 1
)

:: Levantamos los servicios Docker.
docker compose up -d
if errorlevel 1 (
	echo.
	echo ERROR: No se pudo iniciar Docker Compose.
	echo Verifica que Docker Desktop este abierto y que la imagen este cargada.
	echo.
	pause
	exit /b 1
)

:: Cerramos cualquier instancia previa de la aplicacion para evitar conflictos.
:: Esto asegura que siempre arranquemos con una sesion limpia.
::
:: Version anterior:
:: powershell -command "Get-Process brave -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like '*Pilates*' } | Stop-Process -Force" > NUL 2>&1
::
:: Cambio para cliente:
:: - Mantenemos Brave como primera opcion.
:: - Anadimos Edge como alternativa por si el cliente no tiene Brave instalado.
powershell -command "Get-Process brave -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like '*Pilates*' } | Stop-Process -Force" > NUL 2>&1
powershell -command "Get-Process msedge -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like '*Pilates*' } | Stop-Process -Force" > NUL 2>&1

:: Abrimos la aplicación en modo ventana independiente (--app)
echo Abriendo la aplicacion...
echo.

:: Version anterior, mantenida como referencia:
:: start brave --app="http://localhost:3001"

:: Para cliente:
:: - Si Brave existe, se usa como ventana de aplicacion.
:: - Si no existe, se intenta con Edge.
:: - Si tampoco existe, se abre la URL con el navegador predeterminado.
where brave > NUL 2>&1
if not errorlevel 1 (
	start brave --app="http://localhost:3001"
	exit /b 0
)

where msedge > NUL 2>&1
if not errorlevel 1 (
	start msedge --app="http://localhost:3001"
	exit /b 0
)

start "" "http://localhost:3001"

:: Salimos de la terminal inmediatamente
exit /b 0
