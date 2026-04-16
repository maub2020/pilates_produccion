# Configuración Detallada de Nginx Proxy Manager (NPM) con Docker

Esta guía amplía el "Punto 2" de las recomendaciones y te explica paso a paso cómo montar **Nginx Proxy Manager** en tu servidor Linux junto a tu aplicación de Pilates.

Nginx Proxy Manager (NPM) es una interfaz web intuitiva que gestiona dominios web, proxies inversos y certificados SSL gratuitos de Let's Encrypt de forma automática.

## Estructura Recomendada de Directorios en el Servidor

Antes de crear los archivos, te sugiero esta estructura en tu servidor (ej. `/opt/`):
```text
/opt/
├── proxy/             # Carpeta para NPM
│   └── docker-compose.yml
│
└── pilates/           # Carpeta para tu app
    ├── Dockerfile
    ├── docker-compose.yml
    └── db.json
```

---

## 1. Crear la red Docker compartida

Para que NPM pueda conectarse a tu aplicación de Pilates de forma segura (sin exponer puertos directamente a internet innecesariamente), ambas deben estar en la misma red de Docker.

Crea la red ejecutando este comando en tu servidor:
```bash
sudo docker network create web-network
```

---

## 2. Configurar Nginx Proxy Manager (El Gestor)

Ve a la carpeta de tu proxy:
```bash
mkdir -p /opt/proxy
cd /opt/proxy
```

Crea el archivo `docker-compose.yml` para NPM:
```yaml
# /opt/proxy/docker-compose.yml
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      # Puertos públicos de internet
      - '80:80'    # HTTP
      - '443:443'  # HTTPS
      # Puerto para acceder a la interfaz web de administración
      - '81:81'
    environment:
      # Opcional (Base de datos SQLite embebida es suficiente para NPM por defecto)
      DB_SQLITE_FILE: "/data/database.sqlite"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    networks:
      - web-network # Conecta NPM a la red compartida

networks:
  web-network:
    external: true # Le dice a Compose que esta red ya existe (creada en paso 1)
```

Levanta Nginx Proxy Manager:
```bash
sudo docker compose up -d
```

### Configuración inicial de NPM:
1.  Abre tu navegador y ve a: `http://TU_IP_DEL_SERVIDOR:81`
2.  Inicia sesión con las credenciales por defecto:
    *   **Email:** `admin@example.com`
    *   **Password:** `changeme`
3.  El sistema te pedirá cambiar tus datos y contraseña inmediatamente. ¡Hazlo!

---

## 3. Actualizar el docker-compose.yml de tu APP de Pilates

Ahora vuelve a la carpeta de tu app y modifica su `docker-compose.yml` para conectarla a la misma red y ocultar sus puertos al exterior (NPM se encargará del acceso).

Edita `/opt/pilates/docker-compose.yml`:
```yaml
# /opt/pilates/docker-compose.yml
version: '3.8'
services:
  app-pilates:
    build: .
    container_name: pilates_app
    restart: unless-stopped
    volumes:
      - ./db.json:/app/db.json
    environment:
      - NODE_ENV=production
    networks:
      - web-network # Conecta tu app a la red compartida

# No exponemos 'ports:' al exterior (ej. - "3000:3000").
# El contenedor expone el 3000 internamente por defecto, 
# y NPM accederá a él directamente por el nombre del servicio.

networks:
  web-network:
    external: true
```

Reinicia tu aplicación de pilates para aplicar los cambios de red:
```bash
cd /opt/pilates
sudo docker compose down
sudo docker compose up -d --build
```

---

## 4. Unir los conectores desde el panel de NPM

Ahora que ambas aplicaciones están corriendo en la misma `web-network`, es momento de decirle a NPM que envíe el tráfico de tu dominio hacia `app-pilates`.

Asegúrate de que en tu registrador de dominios (GoDaddy, Namecheap, Cloudflare, etc.) has creado un **Récord A** apuntando a la **IP pública de tu servidor Linux**.
*   Por ejemplo: `app.pilates.com` -> `203.0.113.1`

### Pasos en la interfaz de Nginx Proxy Manager:
1.  Inicia sesión en `http://TU_IP_DEL_SERVIDOR:81`
2.  Ve a la pestaña **Hosts** -> **Proxy Hosts**.
3.  Haz clic en el botón verde **Add Proxy Host**.
4.  Rellena la pestaña **Details**:
    *   **Domain Names:** `app.pilates.com` (Tu dominio real)
    *   **Scheme:** `http` (Internamente la app Node habla en texto plano)
    *   **Forward Hostname / IP:** `app-pilates` (Aquí usas el nombre del servicio que definiste en el `docker-compose.yml` de pilates).
    *   **Forward Port:** `3000`
    *   **Cache Assets:** Actívalo (Opcional, pero bueno para rendimiento estático)
    *   **Block Common Exploits:** Actívalo (Seguridad extra)
    *   **Websockets Support:** Actívalo (Si tu app usa conexiones en tiempo real, Vite HMR, etc. Siempre es buena idea).
5.  Pasa a la pestaña **SSL**:
    *   **SSL Certificate:** Selecciona `Request a new SSL Certificate`.
    *   **Force SSL:** Actívalo (Para que HTTP redirija siempre a HTTPS).
    *   **HTTP/2 Support:** Actívalo.
    *   **Email Address for Let's Encrypt:** (Tu correo real para avisos de caducidad, aunque NPM los renueva automáticamente).
    *   **I Agree to the Let's Encrypt Terms:** Márcado.
6.  Haz clic en **Save** y espera unos segundos.

¡Felicidades! NPM acaba de generar un certificado SSL real y ha enrutado tu dominio hacia tu contenedor. Ya puedes acceder a `https://app.pilates.com` de forma segura.
