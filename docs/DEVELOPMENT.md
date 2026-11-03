# Guía de Desarrollo y Entorno Docker (`.devcontainer`)

Esta guía detalla los requisitos técnicos, cómo levantar el entorno de desarrollo en contenedores sin instalar Flutter en tu máquina local, la gestión de permisos/volúmenes y la solución de problemas frecuentes.

---

## 1. Requisitos Previos

El proyecto cuenta con configuración de **Dev Containers (`.devcontainer`)** para aislar todas las herramientas de compilación dentro de Docker.

### Opción A: Desarrollo con Docker / Dev Container (Recomendado)

Solo necesitas tener instalado en tu PC:

1. **[Docker Desktop](https://www.docker.com/products/docker-desktop/)**
   * En Windows: tener activado **WSL 2** y la integración con tu distribución en *Settings → Resources → WSL integration*.
2. **[Visual Studio Code](https://code.visualstudio.com/)** con las extensiones:
   * [**Dev Containers**](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) (`ms-vscode-remote.remote-containers`)
   * *(Opcional en Windows)* [**WSL**](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) (`ms-vscode-remote.remote-wsl`)
3. **Navegador Web** (**Google Chrome** o **Microsoft Edge**) para abrir `http://localhost:8080` y utilizar el micrófono en las funciones de reconocimiento de voz.
4. **Backend API (.NET / IIS Express)** ejecutándose en:
   ```text
   https://localhost:44324/api
   ```

---

### Opción B: Desarrollo Local (Sin Docker)

Si prefieres ejecutarlo de forma nativa en tu sistema operativo:

* **Flutter SDK** (`stable`, con **Dart SDK `^3.13.3`**)
* **Visual Studio Code** con las extensiones `Dart-Code.flutter` y `Dart-Code.dart-code`
* **Google Chrome** (para ejecutar en Web) o **Android Studio** (únicamente si deseas compilar el `.apk` o usar un emulador Android)

---

## 2. Levantar el Proyecto con Dev Containers

### Paso 1: Clonar el repositorio y abrir en VS Code

```bash
git clone git@github.com:bGalvanGuerrero09/UPN-INVENTARIO2.git
cd UPN-INVENTARIO2
code .
```

### Paso 2: Reabrir en el Contenedor

1. En **VS Code**, presiona **`F1`** (o **`Ctrl + Shift + P`**).
2. Selecciona:
   ```text
   Dev Containers: Reopen in Container
   ```
3. **¿Qué configura automáticamente el contenedor?**
   * Construye una imagen basada en `debian:13-slim` con el usuario `web`, terminal `zsh` + `starship` y el **Flutter SDK (`stable`)** preinstalado en `/home/web/flutter`.
   * **Sincroniza automáticamente el `UID/GID` (`updateRemoteUserUID: true`):** Si tu usuario en WSL/Linux es `1000`, `2000` o cualquier otro, VS Code adapta automáticamente el UID del usuario `web` dentro del contenedor creando una capa local (`vsc-upn-inventario2-...-uid`) para evitar conflictos de permisos en los archivos compartidos.
   * Instala automáticamente las extensiones de VS Code declaradas en [`.devcontainer/devcontainer.json`](../.devcontainer/devcontainer.json).
   * Monta tus llaves SSH (`~/.ssh`) y GPG (`~/.gnupg`).
   * Ajusta los permisos de los volúmenes persistentes y ejecuta `flutter pub get` (`postCreateCommand`).

> **Importante:** Levanta siempre el entorno desde VS Code con **`Dev Containers: Reopen in Container`**. Evita levantarlo manualmente con `docker compose up` por terminal en WSL si tu usuario local tiene un UID distinto de `1000`, ya que es la extensión Dev Containers la que sincroniza tu UID automáticamente.
>
> **Nota:** La **primera vez** que se construye el contenedor tardará entre **2 y 4 minutos** descargando el SDK de Flutter y los artefactos Web. En los siguientes inicios abrirá en pocos segundos gracias a la caché de Docker.

---

### Paso 3: Ejecutar la aplicación Flutter dentro del contenedor

Abre la terminal integrada de VS Code (`Ctrl + ñ` o `` Ctrl + ` ``) dentro del contenedor y ejecuta:

```bash
make dev
```

*(Internamente ejecuta `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`).*

Luego abre en el navegador de tu PC:

👉 **[http://localhost:8080](http://localhost:8080)**

#### Otros comandos útiles con `make`:
* `make install` → Instala dependencias (`flutter pub get`)
* `make lint` → Analiza el código (`flutter analyze`)
* `make test` → Ejecuta pruebas (`flutter test`)
* `make build` → Compila versión Web (`flutter build web`)
* `make clean` → Limpia artefactos de compilación (`flutter clean`)

#### Atajos útiles en la terminal mientras corre `make dev`:
* **`r`** → **Hot Reload** (aplica cambios en caliente).
* **`R`** → **Hot Restart** (reinicia el estado completo de la aplicación).
* **`q`** → Detiene el servidor.

---

## 3. Volúmenes y Persistencia (`.devcontainer/docker-compose.yml`)

| Origen (Host / Volumen) | Destino (Contenedor) | Propósito |
| :--- | :--- | :--- |
| `..` | `/home/web/sites/cloud/UPN-INVENTARIO2` | Código fuente del proyecto sincronizado en tiempo real |
| `~/.ssh` | `/home/web/.ssh:ro` | Llaves SSH en solo lectura para operaciones Git (`push` / `pull`) |
| `~/.gnupg` | `/home/web/.gnupg` | Llaves GPG para firma de commits (`export GPG_TTY=$(tty)`) |
| `vscode-server` | `/home/web/.vscode-server` | Persistencia del servidor y extensiones instaladas de VS Code |
| `flutter-pub-cache` | `/home/web/.pub-cache` | Caché persistente de paquetes descargados por `flutter pub get` |

---

## 4. Solución de Problemas Frecuentes (Troubleshooting)

### 1. VS Code se queda esperando en `Start: Run in Host: docker version --format {{json .}}` (WSL2)
* **Causa:** El puente de *Docker Desktop WSL Integration* (`/var/run/docker.sock`) se ha bloqueado en la distribución WSL.
* **Solución:**
  1. Cierra **Docker Desktop** en Windows.
  2. Abre **PowerShell** en Windows y ejecuta:
     ```powershell
     wsl --shutdown
     ```
  3. Inicia nuevamente **Docker Desktop**, espera a que indique *"Engine running"* y vuelve a ejecutar `Dev Containers: Reopen in Container`.

### 2. Error al iniciar sesión: `Error de conexión con el servidor`
* **Causa:** El Backend no está corriendo o el navegador bloquea el certificado HTTPS autofirmado de desarrollo (`https://localhost:44324`).
* **Solución:**
  1. Verifica que la API (.NET / IIS Express) esté activa en `https://localhost:44324/api`.
  2. Abre `https://localhost:44324/api/Producto/ListarProducto` en una pestaña de Chrome y acepta el certificado local antes de iniciar sesión desde `http://localhost:8080`.
