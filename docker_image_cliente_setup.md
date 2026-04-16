# Flujo completo para entregar una imagen Docker al cliente

Este documento explica el proceso completo: desde generar la imagen en tu ordenador hasta dejar la aplicación funcionando en el equipo del cliente.

## 1. Preparación en tu equipo

Abre una terminal en la carpeta del proyecto:

```powershell
cd D:\proyectos\pilates_produccion
```

Comprueba si ya tienes la imagen creada:

```powershell
docker images
```

Si todavía no la has generado, constrúyela:

```powershell
docker compose build
```

## 2. Ponerle un nombre claro a la imagen

Si la imagen actual tiene un nombre poco claro o generado automáticamente, crea una etiqueta más fácil de identificar.

En este proyecto, la imagen local detectada es:

```powershell
pilates-pilates-app:latest
```

Como nombre final recomendado para entrega, se usará:

```powershell
pilates-cliente:v1
```

La idea es simple: mantener el nombre técnico local si quieres, pero entregar al cliente un nombre de imagen claro, corto y estable.

Para conseguirlo, crea una etiqueta adicional.

Ejemplo:

```powershell
docker tag pilates-pilates-app:latest pilates-cliente:v1
```

Si no sabes el nombre exacto, usa primero:

```powershell
docker images
```

Y luego sustituye el nombre original por el correcto.

## 3. Exportar la imagen a un archivo

Crea una carpeta de salida para preparar lo que vas a entregar:

```powershell
mkdir D:\pilates_export
cd D:\pilates_export
```

Exporta la imagen recomendada para cliente:

```powershell
docker save -o pilates-cliente-v1.tar pilates-cliente:v1
```

Opcionalmente, la puedes comprimir en zip para enviarla más fácilmente:

```powershell
Compress-Archive -Path .\pilates-cliente-v1.tar -DestinationPath .\pilates-cliente-v1.zip
```

Al terminar tendrás uno de estos archivos para entregar:

- `pilates-cliente-v1.tar`
- `pilates-cliente-v1.zip`

## 4. Archivos que debes entregar al cliente

Además de la imagen exportada, entrega estos archivos:

- `docker-compose.yml`
- `Abre_Pilates.bat`
- una copia inicial de la base de datos `db.json`

La base de datos inicial debe copiarse desde:

```text
D:\proyectos\pilates_produccion\server\db.json
```

Puedes preparar una carpeta final así:

```text
D:\pilates_export\entrega_cliente\
  pilates-cliente-v1.tar
  docker-compose.yml
  Abre_Pilates.bat
  db.json
```

## 5. Qué tiene que hacer el cliente

El cliente debe tener instalado Docker Desktop y tenerlo arrancado.

Después debe copiar todos los archivos a una carpeta de su equipo, por ejemplo:

```text
C:\pilates
```

### 5.1. Cargar la imagen Docker

Abrir PowerShell y entrar en la carpeta donde está el archivo exportado:

```powershell
cd C:\pilates
```

Si le entregaste un `.tar`, cargar la imagen así:

```powershell
docker load -i .\pilates-cliente-v1.tar
```

Si primero descomprimió un zip, entonces debe cargar el `.tar` resultante.

Después puede verificar que la imagen está disponible:

```powershell
docker images
```

Debe aparecer algo parecido a esto:

```text
REPOSITORY         TAG    IMAGE ID       CREATED        SIZE
pilates-cliente    v1     xxxxxxxxxxxx   hace un rato   xxxMB
```

## 6. Preparar la base de datos en el equipo del cliente

Tu `docker-compose.yml` actual monta este archivo local del cliente:

```text
C:/data/db.json
```

Por tanto, en el ordenador del cliente hay que crear esa ruta y copiar ahí la base de datos inicial.

En PowerShell:

```powershell
mkdir C:\data
copy .\db.json C:\data\db.json
```

## 7. Ajuste necesario en docker-compose.yml para usar la imagen exportada

Tu `docker-compose.yml` original estaba pensado para construir la imagen en local con `build:`. Eso sirve en desarrollo o en tu propio equipo, pero en el ordenador del cliente quieres usar directamente la imagen ya exportada.

Por tanto, en el archivo `docker-compose.yml` que le entregues al cliente, el servicio principal debe quedar así:

```yaml
services:
  pilates-app:
    image: pilates-cliente:v1
    container_name: pilates_app
    restart: unless-stopped
    ports:
      - "3001:3000"
    environment:
      NODE_ENV: production
      HOST: 0.0.0.0
      PORT: "3000"
    volumes:
      - "C:/data/db.json:/app/server/db.json"
```

Importante:

- en el cliente no debe quedar el bloque `build:`
- debe usarse `image:` con el nombre exacto de la imagen cargada
- el nombre de la imagen debe coincidir exactamente con el que cargaste con `docker load`

En esta guía, el nombre recomendado para entrega es:

```yaml
image: pilates-cliente:v1
```

Si prefieres no crear una etiqueta adicional, también podrías trabajar con el nombre técnico original:

```yaml
image: pilates-pilates-app:latest
```

Pero para entrega al cliente no es lo más cómodo, porque mezcla el nombre del proyecto local con el nombre interno del servicio. Por eso se recomienda mantener el compose final con:

```yaml
image: pilates-cliente:v1
```

### 7.1. Cambio importante sobre el backup

En una versión anterior, el bloque `command:` del backup podía quedar asociado al servicio principal. Eso no debe hacerse así.

Motivo:

- en Docker Compose, `command:` sustituye el comando por defecto de la imagen
- si pones el bucle de backup dentro de `pilates-app`, el contenedor deja de arrancar la aplicación Nuxt/Nitro
- por eso el backup debe ir en un servicio separado, por ejemplo `pilates-backup`, o dejarse desactivado

## 8. Arrancar la aplicación en el equipo del cliente

Una vez cargada la imagen y preparada la base de datos, el cliente puede iniciar la aplicación.

Desde PowerShell, dentro de la carpeta `C:\pilates`:

```powershell
docker compose up -d
```

Para comprobar que está funcionando:

```powershell
docker compose ps
```

Para ver logs si algo falla:

```powershell
docker compose logs -f
```

## 9. Abrir la aplicación

La aplicación quedará accesible en:

```text
http://localhost:3001
```

Si el cliente usa tu archivo `Abre_Pilates.bat`, el script hará esto:

- comprobará que existe `C:\data\db.json`
- ejecutará `docker compose up -d`
- intentará abrir la app con Brave
- si Brave no existe, probará con Edge
- si tampoco existe, abrirá la URL con el navegador predeterminado

Si falta `C:\data\db.json` o Docker Compose falla, el script mostrará un mensaje y no cerrará la ventana inmediatamente, para que el cliente vea el error.

## 10. Flujo resumido

### En tu equipo

```powershell
cd D:\proyectos\pilates_produccion
docker compose build
docker tag pilates-pilates-app:latest pilates-cliente:v1
mkdir D:\pilates_export
cd D:\pilates_export
docker save -o pilates-cliente-v1.tar pilates-cliente:v1
```

Luego entregas al cliente:

- `pilates-cliente-v1.tar`
- `docker-compose.yml` preparado para `image:`
- `Abre_Pilates.bat`
- `db.json`

### En el equipo del cliente

```powershell
cd C:\pilates
docker load -i .\pilates-cliente-v1.tar
mkdir C:\data
copy .\db.json C:\data\db.json
docker compose up -d
```

Si el `docker-compose.yml` del cliente usa el nombre real sin retag, entonces la exportación y carga podrían hacerse también así:

```powershell
docker save -o pilates-pilates-app-latest.tar pilates-pilates-app:latest
docker load -i .\pilates-pilates-app-latest.tar
```

Y abre:

```text
http://localhost:3001
```

## 11. Problemas habituales

### Docker no arranca

El cliente debe abrir Docker Desktop y esperar a que quede iniciado antes de ejecutar `docker load` o `docker compose up`.

### La imagen no aparece tras `docker load`

Comprobar con:

```powershell
docker images
```

Y revisar que el nombre de la imagen en `docker-compose.yml` coincide exactamente.

### Error porque no existe `C:/data/db.json`

Eso significa que no se creó la carpeta o no se copió el archivo. Debe existir este archivo antes de arrancar el contenedor:

```text
C:\data\db.json
```

### El puerto 3001 está ocupado

Si en el equipo del cliente ya hay algo usando el puerto 3001, cambia esta línea en `docker-compose.yml`:

```yaml
- "3001:3000"
```

por ejemplo por:

```yaml
- "3002:3000"
```

En ese caso la aplicación se abriría en:

```text
http://localhost:3002
```

## 12. Checklist final de entrega

Antes de enviar el paquete al cliente, revisa esto:

- la imagen final que vas a entregar existe con el nombre `pilates-cliente:v1`
- el archivo exportado corresponde a esa imagen, por ejemplo `pilates-cliente-v1.tar` o `pilates-cliente-v1.zip`
- `docker-compose.yml` usa `image: pilates-cliente:v1`
- `docker-compose.yml` no contiene el bloque activo `build:`
- `docker-compose.yml` monta `C:/data/db.json:/app/server/db.json`
- `Abre_Pilates.bat` está incluido
- `db.json` está incluido
- el cliente tiene instrucciones para copiar `db.json` a `C:\data\db.json`
- el cliente tiene instrucciones para ejecutar `docker load -i` antes de `docker compose up -d`
- el cliente sabe que la aplicación abre en `http://localhost:3001`

Comprobación rápida en tu equipo antes de entregar:

```powershell
docker images
docker compose config
```
