# Shopify App — Entorno de Desarrollo Local

Entorno dockerizado para desarrollar una Shopify App con Shopify CLI v3 y Remix, sin instalar dependencias directamente en la máquina host.

---

## Requisitos previos

| Herramienta | Versión mínima |
|---|---|
| Docker Desktop | 4.x |
| Make | cualquiera |
| Cuenta Shopify Partners | gratuita |

> Crear cuenta en [partners.shopify.com](https://partners.shopify.com) → **Stores** → **Add store** → Development store.

---

## Windows

> Esta sección está pensada para alguien que empieza desde cero. Si ya tienes experiencia, ve directo a los comandos.

Antes de empezar, necesitas instalar tres cosas en orden. No te saltes ningún paso.

---

### Paso 1 — Activar WSL2 (el "Linux dentro de Windows")

**¿Qué es esto?** Windows no entiende directamente los mismos comandos que Linux o macOS. WSL2 es una función gratuita de Windows que instala un Linux real dentro de tu PC, sin borrar nada ni cambiar tu Windows. Lo usaremos para ejecutar el proyecto.

**¿Cómo se instala?**

1. Pulsa la tecla `Windows` en tu teclado y escribe: `PowerShell`
2. Haz clic derecho sobre **Windows PowerShell** → **Ejecutar como administrador**

   > Te preguntará si quieres permitir cambios en el equipo → pulsa **Sí**

3. Escribe este comando y pulsa Enter:

   ```powershell
   wsl --install
   ```

4. Espera a que termine (puede tardar unos minutos) y **reinicia el ordenador** cuando te lo pida.

5. Al volver a encender el PC, se abrirá automáticamente una ventana de Ubuntu (Linux) pidiendo que crees un usuario y contraseña. Pon el nombre que quieras y una contraseña que recuerdes.

   > Cuando escribas la contraseña no verás los caracteres en pantalla — es normal, es una medida de seguridad. Escríbela igualmente y pulsa Enter.

Ya tienes Linux dentro de tu Windows. Para abrirlo en el futuro busca **Ubuntu** en el menú de inicio.

---

### Paso 2 — Instalar Docker Desktop

**¿Qué es Docker?** Es el programa que permite ejecutar el proyecto en un entorno aislado, sin instalar Node.js, ni Shopify, ni nada más directamente en tu PC. Todo queda contenido dentro de Docker.

1. Ve a [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) y descarga **Docker Desktop para Windows**
2. Ejecuta el instalador. Cuando te pregunte, asegúrate de que está marcada la opción **"Use WSL 2 based engine"**
3. Cuando termine, abre Docker Desktop
4. Ve a **Settings** (el engranaje arriba a la derecha) → **Resources** → **WSL Integration**
5. Activa el interruptor que aparece junto a **Ubuntu**
6. Pulsa **Apply & Restart**

   > Docker Desktop debe estar abierto y con el icono verde en la barra de tareas cada vez que uses el proyecto.

---

### Paso 3 — Instalar `make` en Ubuntu

`make` es la herramienta que permite escribir comandos cortos como `make build` en lugar de comandos largos. La instalamos dentro de Ubuntu (no en Windows).

1. Abre **Ubuntu** desde el menú de inicio
2. Escribe este comando y pulsa Enter:

   ```bash
   sudo apt update && sudo apt install -y make
   ```

   > Te pedirá tu contraseña de Ubuntu (la que creaste en el Paso 1)

---

### Paso 4 — Descargar el proyecto

Ahora descargamos el código en tu ordenador. Es importante hacerlo **desde la terminal de Ubuntu**, no desde el Explorador de archivos de Windows.

1. Abre **Ubuntu**
2. Ejecuta estos comandos uno a uno:

   ```bash
   cd ~
   git clone <url-del-repositorio> shopify-sito
   cd shopify-sito
   ```

   > Sustituye `<url-del-repositorio>` por la URL real del proyecto.

   > **¿Por qué no usar el Explorador de archivos?** Los archivos del proyecto deben vivir dentro del sistema de ficheros de Ubuntu (la carpeta `~`), no en `C:\Usuarios\...`. Si los pones en Windows, Docker irá muy lento y puede dar errores de permisos.

---

### Paso 5 — Arrancar el proyecto

Ya está todo listo. Desde la terminal de Ubuntu, dentro de la carpeta `shopify-sito`:

```bash
make build   # Solo la primera vez: construye el entorno
make init    # Solo la primera vez: configura la app con tu cuenta Shopify
make dev     # Cada vez que quieras trabajar: arranca el servidor
```

Cuando quieras parar:

```bash
make down
```

---

### Solución al error más común en Windows

Si al hacer `make build` aparece el error `exec format error` o `/bin/bash^M: bad interpreter`, significa que Windows ha modificado un archivo del proyecto añadiendo caracteres invisibles incompatibles con Linux.

Solución rápida desde Ubuntu:

```bash
sudo apt install -y dos2unix
dos2unix scripts/entrypoint.sh
```

O si usas VS Code: abre `scripts/entrypoint.sh` → mira la barra inferior derecha → si pone `CRLF` haz clic y cámbialo a `LF` → guarda el archivo.

---

## Inicio rápido

### Primera vez (setup completo)

```bash
# 1. Construir la imagen Docker
make build

# 2. Scaffold interactivo de la app (solo se ejecuta una vez)
make init
```

Durante `make init` el CLI mostrará:

```
User verification code: XXXX-XXXX
  → Open in your browser: https://accounts.shopify.com/activate-with-code?...
```

**Pasos de autenticación:**
1. Abre la URL en tu browser
2. Inicia sesión con tu cuenta Shopify Partners
3. Introduce el código de verificación que aparece en la terminal
4. El CLI continuará automáticamente pidiendo:
   - Nombre de la app
   - Template → seleccionar **Remix**
   - Development store a la que conectarla

El código generado queda en `./app/` en tu máquina local.

---

### Desarrollo diario

```bash
# Arrancar el servidor de desarrollo con hot reload
make dev
```

La app estará disponible en `http://localhost:3000`.

El CLI levanta automáticamente un tunnel de Cloudflare para que Shopify pueda enviar webhooks a tu entorno local.

---

### Parar el proyecto

```bash
make down
```

---

### Limpiar todo (reset completo)

Elimina contenedores, volúmenes (incluidas las credenciales guardadas) e imagen:

```bash
make clean
```

Después de `make clean` es necesario volver a ejecutar `make build && make init`.

---

## Referencia de comandos

| Comando | Descripción |
|---|---|
| `make build` | Construye la imagen Docker |
| `make init` | Setup inicial: scaffold de la app (interactivo, una sola vez) |
| `make dev` | Arranca el servidor de desarrollo con hot reload |
| `make down` | Para todos los contenedores |
| `make clean` | Reset completo: elimina contenedores, volúmenes e imagen |

---

## Funcionalidades

- **Entorno reproducible:** todo el toolchain (Node.js, Shopify CLI) corre dentro de Docker; la máquina host no se modifica.
- **Hot reload:** cambios en `./app/` se reflejan en el browser sin reiniciar el contenedor.
- **Auth persistente:** las credenciales de Shopify CLI se guardan en un volumen Docker nombrado (`shopify-config`), por lo que no es necesario autenticarse en cada arranque.
- **Tunnel automático:** Shopify CLI gestiona un tunnel de Cloudflare para exponer el servidor local a internet, necesario para el flujo OAuth y webhooks.
- **Código en host:** `./app/` está montado como volumen, por lo que puedes editar con cualquier editor local (VS Code, Cursor, etc.) y los cambios se sincronizan en tiempo real al contenedor.

---

## Arquitectura técnica

### Diagrama de componentes

```
┌─────────────────────────────────────────────────────┐
│  Host (macOS)                                        │
│                                                      │
│  ./app/  ──────────────────────────────────────────┐ │
│  (código fuente)                                   │ │
│                                                    ▼ │
│  ┌─────────────────────────────────────────────────┐ │
│  │  Docker Container: shopify                      │ │
│  │                                                 │ │
│  │  node:20-alpine                                 │ │
│  │  ├── @shopify/cli (global)                      │ │
│  │  ├── Remix app (./app → /workspace/app)         │ │
│  │  └── shopify app dev → :3000                   │ │
│  │                          │                      │ │
│  └──────────────────────────┼──────────────────────┘ │
│                             │ port 3000              │
│  browser ───────────────────┘                        │
│                                                      │
│  Volume: shopify-config                              │
│  └── /home/node/.config  (credenciales CLI)          │
└─────────────────────────────────────────────────────┘
                    │ Cloudflare Tunnel
                    ▼
         ┌──────────────────┐
         │  Shopify Cloud   │
         │  (dev store API  │
         │   + webhooks)    │
         └──────────────────┘
```

### Stack

| Capa | Tecnología | Justificación |
|---|---|---|
| Runtime | Node.js 20 Alpine | LTS, imagen mínima |
| Framework | Remix | Template oficial de Shopify para apps |
| CLI | Shopify CLI v3 | Gestiona auth, tunnel y dev server |
| Tunnel | Cloudflare (gestionado por CLI) | Necesario para OAuth y webhooks desde Shopify |
| Containerización | Docker + Compose | Entorno reproducible sin dependencias en host |

### Volúmenes Docker

| Volumen | Mount en contenedor | Propósito |
|---|---|---|
| `./app` (bind mount) | `/workspace/app` | Código fuente editable desde el host |
| `shopify-config` (named) | `/home/node/.config` | Credenciales y sesión del CLI persistentes |

### Variables de entorno

Definidas en `.env` (basado en `.env.example`):

| Variable | Descripción |
|---|---|
| `SHOPIFY_CLI_PARTNERS_TOKEN` | Token de la API de Partners (opcional, para CI) |
| `SHOPIFY_API_KEY` | API Key de la app (generada tras `make init`) |
| `SHOPIFY_API_SECRET` | API Secret de la app (generada tras `make init`) |

> `.env` está en `.gitignore`. Nunca commitear credenciales.

### Decisiones de diseño notables

- **`xdg-open` shim:** Alpine no tiene lanzador de browser. El CLI llama a `xdg-open` para abrir la URL de auth automáticamente; sin el shim el proceso muere con `ENOENT`. El shim imprime la URL y sale con código 0 para que el CLI continúe esperando el callback OAuth.
- **`/home/node/.config` como mount point del volumen:** El CLI crea múltiples subdirectorios dentro de `.config` (`shopify`, `shopify-cli-kit-nodejs`, etc.). Montar solo uno de ellos causaba errores de permisos en los hermanos. Montar el padre resuelve todos los casos.
- **Usuario no-root:** El contenedor corre como `node` (uid=1000). El directorio `.config` se pre-crea como root en el Dockerfile con `chown` antes de hacer `USER node`, para que el volumen Docker (que monta como root) no bloquee la escritura.

---

## Estructura del proyecto

```
shopify-sito/
├── Dockerfile              # Imagen base con Node 20 + Shopify CLI
├── docker-compose.yml      # Servicio, puertos y volúmenes
├── Makefile                # Comandos de desarrollo
├── .env                    # Variables de entorno (no commitear)
├── .env.example            # Plantilla de variables de entorno
├── .gitignore
├── scripts/
│   └── entrypoint.sh       # Lógica init vs dev del contenedor
└── app/                    # Código de la Shopify App (generado por make init)
    ├── app/                # Rutas Remix
    ├── extensions/         # Extensiones de Shopify (UI, funciones, etc.)
    └── shopify.app.toml    # Configuración de la app
```
