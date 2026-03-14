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
