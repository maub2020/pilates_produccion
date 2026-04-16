@echo off
REM ============================================================
REM  BACKUP AUTOMATICO DE ARCHIVO CON CONTROL DE CAMBIOS
REM ============================================================
REM
REM  DESCRIPCION:
REM  Este script realiza copias periodicas de un archivo origen
REM  a una carpeta destino, anadiendo al nombre de la copia la
REM  abreviatura del dia de la semana (Lun, Mar, Mie, Jue, Vie,
REM  Sab, Dom). De este modo se mantienen automaticamente hasta
REM  7 copias rotativas (una por dia).
REM
REM  Antes de copiar comprueba si el archivo destino ya existe
REM  y si su fecha de modificacion es igual o posterior a la del
REM  origen. Si no ha habido cambios, omite la copia sin mostrar
REM  mensaje. Si el origen fue modificado, realiza la copia y
REM  muestra una notificacion en pantalla durante unos segundos.
REM  Si ocurre un error, muestra el error en pantalla.
REM
REM  Todas las operaciones quedan registradas en un archivo log.
REM
REM  REQUISITOS:
REM  - Windows 10 o superior
REM  - PowerShell 5.1 o superior (incluido en Windows 10/11)
REM
REM  VARIABLES A CONFIGURAR (seccion CONFIGURACION):
REM
REM    ORIGEN    - Ruta completa del archivo a copiar (con nombre
REM               y extension). Ejemplo: D:\datos\base.accdb
REM
REM    DESTINO   - Carpeta donde se guardaran las copias (sin
REM               barra final). Se crea automaticamente si no
REM               existe. Ejemplo: E:\backups\datos
REM
REM    INTERVALO - Tiempo entre comprobaciones en SEGUNDOS.
REM               Ejemplos: 3600 = 1 hora, 1800 = 30 minutos,
REM               900 = 15 minutos, 60 = 1 minuto
REM
REM    LOG       - Ruta completa del archivo de log. Si se deja
REM               vacio, se guarda como backup.log en DESTINO.
REM               Ejemplo: D:\logs\backup_datos.log
REM
REM    MSG_SEG   - Segundos que permanece visible la notificacion
REM               en pantalla. Ejemplo: 5
REM
REM  COMO LANZAR AL INICIAR WINDOWS (en segundo plano):
REM
REM  Opcion A - Programador de tareas (recomendada, sin ventana garantizado):
REM    Es la opcion mas robusta: no aparece ninguna ventana ni entrada en la
REM    barra de tareas, y es mas fiable ante reinicios que las otras opciones.
REM    Ejecutar como administrador en cmd (ajusta la ruta al .bat):
REM    schtasks /create /tn "BackupDatos" /tr "cmd.exe /c start /min \"\" \"C:\ruta\CronWindowsCopia.bat\"" /sc onlogon /rl highest /f
REM
REM    Para eliminarlo:
REM    schtasks /delete /tn "BackupDatos" /f
REM
REM    Para ver si existe:
REM    schtasks /query /tn "BackupDatos"
REM
REM  Opcion B - Carpeta de inicio con .vbs (sin ventana ni icono en barra):
REM    1. Crear un archivo LanzarBackup.vbs con este contenido:
REM       CreateObject("WScript.Shell").Run "cmd /c ""C:\ruta\CronWindowsCopia.bat""", 0, False
REM    2. Pulsar Win+R, escribir shell:startup y pulsar Enter
REM    3. Copiar el archivo LanzarBackup.vbs a esa carpeta
REM    Al iniciar sesion el script arrancara completamente invisible,
REM    sin ventana ni entrada en la barra de tareas.
REM
REM  Opcion C - Carpeta de inicio con acceso directo (aparece minimizado):
REM    1. Pulsar Win+R, escribir shell:startup y pulsar Enter
REM    2. Crear un acceso directo al archivo .bat en esa carpeta
REM    3. Click derecho en el acceso directo > Propiedades
REM       > Ejecutar: Minimizada
REM
REM  PARA DETENER EL SCRIPT:
REM    Abrir Administrador de tareas (Ctrl+Shift+Esc), buscar
REM    el proceso cmd.exe del script y finalizarlo.
REM
REM ============================================================

setlocal EnableDelayedExpansion

REM ============================================================
REM  CONFIGURACION - Modifica estas variables
REM ============================================================

REM Ruta completa del archivo origen (nombre y extension)
set "ORIGEN=D:\prueba\test.txt"

REM Carpeta destino para las copias (sin barra final)
set "DESTINO=D:\backup"

REM Intervalo entre comprobaciones en SEGUNDOS
set "INTERVALO=60"

REM Ruta del log (dejar vacio para usar DESTINO\backup.log)
set "LOG="

REM Segundos que se muestra la notificacion en pantalla
set "MSG_SEG=5"

REM ============================================================
REM  INICIO - NO MODIFICAR DEBAJO DE ESTA LINEA
REM ============================================================

REM Configurar ruta del log si no se definio
if "%LOG%"=="" set "LOG=%DESTINO%\backup.log"

REM Crear carpeta del log si no existe
for %%L in ("%LOG%") do (
    if not exist "%%~dpL" mkdir "%%~dpL"
)

echo [%date% %time%] === INICIO DEL SCRIPT DE BACKUP === >> "%LOG%"
echo [%date% %time%] Origen: %ORIGEN% >> "%LOG%"
echo [%date% %time%] Destino: %DESTINO% >> "%LOG%"
echo [%date% %time%] Intervalo: %INTERVALO% segundos >> "%LOG%"

:BUCLE
REM Obtener dia de la semana en ingles y mapear a espanol sin tildes
for /f "tokens=1" %%d in ('powershell -NoProfile -Command "(Get-Date).DayOfWeek"') do set "DIAEN=%%d"

if "%DIAEN%"=="Monday"    set "DIA=Lun"
if "%DIAEN%"=="Tuesday"   set "DIA=Mar"
if "%DIAEN%"=="Wednesday" set "DIA=Mie"
if "%DIAEN%"=="Thursday"  set "DIA=Jue"
if "%DIAEN%"=="Friday"    set "DIA=Vie"
if "%DIAEN%"=="Saturday"  set "DIA=Sab"
if "%DIAEN%"=="Sunday"    set "DIA=Dom"

REM Extraer nombre y extension del archivo origen
for %%F in ("%ORIGEN%") do (
    set "NOMBRE=%%~nF"
    set "EXT=%%~xF"
)

REM Construir ruta destino: nombre_Lun.ext, nombre_Mar.ext, etc.
set "ARCHIVO_DESTINO=%NOMBRE%_%DIA%%EXT%"
set "RUTA_DESTINO=%DESTINO%\%ARCHIVO_DESTINO%"

REM Crear carpeta destino si no existe
if not exist "%DESTINO%" mkdir "%DESTINO%"

REM Verificar que el archivo origen existe
if not exist "%ORIGEN%" (
    set "ERROR_MSG=Archivo origen no encontrado: %ORIGEN%"
    echo [%date% %time%] ERROR: !ERROR_MSG! >> "%LOG%"
    goto :MOSTRAR_ERROR
)

REM Comprobar si la copia existente ya es igual o mas reciente que el origen
set "ACCION=COPY"
if exist "%RUTA_DESTINO%" (
    for /f "tokens=*" %%r in ('powershell -NoProfile -Command ^
        "try { if ((Get-Item -LiteralPath '%RUTA_DESTINO%').LastWriteTime -ge (Get-Item -LiteralPath '%ORIGEN%').LastWriteTime) { 'SKIP' } else { 'COPY' } } catch { 'COPY' }"') do set "ACCION=%%r"
)

REM Si no hay cambios, omitir sin mensaje
if "!ACCION!"=="SKIP" (
    rem echo [%date% %time%] OMITIDA: %ARCHIVO_DESTINO% - sin cambios en el origen >> "%LOG%"
    goto :ESPERAR
)

REM Realizar la copia (sobrescribe sin preguntar)
copy /Y "%ORIGEN%" "%RUTA_DESTINO%" >nul 2>&1

if !ERRORLEVEL! equ 0 (
    echo [%date% %time%] BACKUP: %ARCHIVO_DESTINO% >> "%LOG%"
    goto :MOSTRAR_OK
) else (
    set "ERROR_MSG=Error al copiar %ARCHIVO_DESTINO% a %DESTINO%"
    echo [%date% %time%] ERROR: !ERROR_MSG! >> "%LOG%"
    goto :MOSTRAR_ERROR
)

:MOSTRAR_OK
REM Notificacion de exito (no bloqueante, desaparece sola)
start "" /b powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Add-Type -AssemblyName System.Windows.Forms; " ^
    "$n = New-Object System.Windows.Forms.NotifyIcon; " ^
    "$n.Icon = [System.Drawing.SystemIcons]::Information; " ^
    "$n.BalloonTipIcon = 'Info'; " ^
    "$n.BalloonTipTitle = 'Backup'; " ^
    "$n.BalloonTipText = 'Copia de datos realizada: %ARCHIVO_DESTINO%'; " ^
    "$n.Visible = $true; " ^
    "$n.ShowBalloonTip(%MSG_SEG%000); " ^
    "Start-Sleep -Seconds (%MSG_SEG% + 1); " ^
    "$n.Dispose()"
goto :ESPERAR

:MOSTRAR_ERROR
REM Notificacion de error (no bloqueante, desaparece sola)
start "" /b powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Add-Type -AssemblyName System.Windows.Forms; " ^
    "$n = New-Object System.Windows.Forms.NotifyIcon; " ^
    "$n.Icon = [System.Drawing.SystemIcons]::Warning; " ^
    "$n.BalloonTipIcon = 'Error'; " ^
    "$n.BalloonTipTitle = 'Backup - ERROR'; " ^
    "$n.BalloonTipText = '!ERROR_MSG!'; " ^
    "$n.Visible = $true; " ^
    "$n.ShowBalloonTip(%MSG_SEG%000); " ^
    "Start-Sleep -Seconds (%MSG_SEG% + 1); " ^
    "$n.Dispose()"
goto :ESPERAR

:ESPERAR
timeout /t %INTERVALO% /nobreak >nul
goto :BUCLE