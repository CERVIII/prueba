📋 Guía Paso a Paso - Requisitos del Proyecto Inception
Basada en el documento de corrección, aquí está lo que debes verificar y hacer:

FASE 1: Verificaciones Iniciales ✅
1️⃣ Limpieza de Docker (antes de evaluación)
2️⃣ Estructura del Proyecto
✅ Carpeta srcs en la raíz con todos los archivos
✅ Makefile en la raíz
✅ README.md en la raíz
✅ USER_DOC.md en la raíz
✅ DEV_DOC.md en la raíz
3️⃣ Revisar docker-compose.yml
❌ NO debe tener network: host
❌ NO debe tener links:
✅ DEBE tener networks: definidas
✅ DEBE tener volumes: definidos
FASE 2: Documentación 📖
README.md
✅ Primera línea: "This project has been created as part of the 42 curriculum by pcervill" (en cursiva)
✅ Secciones: Description, Instructions, Readme check, AI usage explanation
USER_DOC.md
✅ Instrucciones básicas para usuarios finales
✅ Cómo iniciar servicios
✅ Cómo acceder al sitio
✅ Gestión de credenciales
DEV_DOC.md
✅ Requisitos previos
✅ Instrucciones de setup
✅ Comandos del Makefile
✅ Explicación de persistencia de datos
FASE 3: Docker Basics 🐳
Dockerfiles (IMPORTANTE)
✅ 1 Dockerfile por servicio (nginx, wordpress, mariadb)
✅ Deben estar en: srcs/requirements/[service]/Dockerfile
✅ Base: FROM alpine:3.21 (o versión estable similar)
✅ NO usar imágenes listas de DockerHub - deben ser propias
Verificación:
FASE 4: Docker Network 🌐
Verificar:
Debes saber explicar:

Qué es docker-network
Por qué se usa en lugar de links
FASE 5: NGINX con SSL/TLS 🔒
Verificaciones:
Abrir en navegador:
URL: https://pcervill.42.fr
✅ Ver página de WordPress (NO la página de instalación)
✅ Certificado SSL/TLS v1.2 o v1.3
✅ Advertencia de certificado autofirmado es OK
Verificación en Dockerfile:
FASE 6: WordPress con PHP-FPM 📝
Verificaciones:
En el navegador:
Ir a https://pcervill.42.fr
✅ Página de WordPress funciona
Crear comentario con usuario NO-admin
Iniciar sesión con admin (⚠️ NO debe ser "admin", "Admin", "administrator")
✅ Editar página desde admin panel
✅ Ver cambios en el sitio
Verificación de volumen:
FASE 7: MariaDB y Volumen 🗄️
Verificaciones:
Acceder a la base de datos:
Verificación de volumen:
FASE 8: Persistencia de Datos 💾
Procedimiento crítico:
✅ Realizar cambios en WordPress (editar página, agregar comentarios)
✅ Detener contenedores:
✅ Reiniciar:
✅ Verificar que:
WordPress sigue funcionando
Los cambios realizados persisten
La base de datos tiene los datos
FASE 9: Modificación de Configuración ⚙️
El evaluador puede pedirte cambiar:
Puerto de NGINX (por ejemplo de 443 a 8443)
Credenciales de base de datos
Dominio (pcervill.42.fr a otro)
Proceso:
Editar el valor en .env o Makefile
Ejecutar:
✅ Verificar que funciona con la nueva configuración
CHECKLIST FINAL ✨
 README.md con formato correcto
 USER_DOC.md y DEV_DOC.md presentes y completos
 3 Dockerfiles propios (Alpine 3.21)
 docker-compose.yml sin links ni network: host
 Red Docker creada y funcionando
 NGINX solo en puerto 443 HTTPS
 Certificado SSL/TLS v1.2 o v1.3
 WordPress funciona sin página de instalación
 Usuario admin NO es "admin" o "Admin"
 PHP-FPM funcionando
 Volumen WordPress persiste
 MariaDB funciona
 Volumen MariaDB persiste
 Datos persisten después de reinicio
 Cambios de configuración se aplican correctamente