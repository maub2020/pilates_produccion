# syntax=docker/dockerfile:1

# Este Dockerfile usa "multi-stage build" para conseguir una imagen final
# ligera: una etapa compila la app y la segunda solo ejecuta lo necesario.

# ==============================
# 1) ETAPA DE COMPILACION (builder)
# ==============================
# Imagen base con Node.js 24 sobre Alpine (ligera y estable para producción).
FROM node:24-alpine AS builder

# Directorio de trabajo dentro del contenedor para todas las instrucciones
# siguientes de esta etapa.
WORKDIR /app

# Se copian primero los archivos de dependencias para aprovechar la cache de
# capas de Docker: si no cambian package*.json, no reinstala paquetes.
COPY package*.json ./

# Instalación reproducible basada en package-lock.json.
RUN npm ci

# Forzamos reconstrucción ante cambios
ARG CACHE_BUST=1

# Copia del resto del código del proyecto.
COPY . .

# Compila Nuxt 4 y genera .output para ejecución en producción.
RUN npm run build

# ==============================
# 2) ETAPA DE EJECUCION (runner)
# ==============================
# Segunda imagen limpia para runtime (más pequeña y segura).
FROM node:24-alpine AS runner

# Directorio de trabajo en la imagen final.
WORKDIR /app

# Se copia únicamente la salida compilada de Nuxt/Nitro.
COPY --from=builder /app/.output ./.output

# Se prepara la carpeta de datos donde la API lee/escribe la base JSON.
RUN mkdir -p /app/server

# Se copia una DB inicial. Cuando se use volumen nombrado sobre /app/server,
# Docker inicializará ese volumen con este contenido en el primer arranque.
COPY --from=builder /app/server/db.json /app/server/db.json

# Variables de entorno de runtime para Nuxt/Nitro en producción.
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

# Puerto interno documentado por la imagen.
EXPOSE 3000

# Comando de arranque del servidor Nitro compilado.
CMD ["node", ".output/server/index.mjs"]
