# Sistema de Inventario — UPN (`inventariofinal`)

Aplicación multiplataforma desarrollada en **Flutter** para el control y gestión de inventario, implementada bajo arquitectura **MVVM (`ChangeNotifier`)** e integrada con **reconocimiento de voz en español (`es-PE`)**.

---

## Características Principales

* **Autenticación de Usuarios (`Login`):** Validación de credenciales contra el servicio REST institucional.
* **Registro de Ingresos (`Ingreso`):** Entrada de stock mediante selección manual o dictado por voz indicando **cantidad + producto** (ej. *"10 Paracetamol"*).
* **Registro de Salidas (`Salida`):** Salida de stock con búsqueda manual o por voz y validación automática de stock disponible.
* **Historial de Movimientos (`Movimientos`):** Consulta de entradas (`ING`) y salidas (`SAL`) con filtros combinables por **Producto** y **Usuario**, mostrando el stock actual del producto seleccionado.
* **Búsqueda de Productos (`Buscar`):** Filtrado en tiempo real por texto o por voz (código, nombre, unidad o área) y vista detallada del producto.
* **Alta de Productos (`NuevoProducto`):** Registro de nuevos productos con carga dinámica de catálogos de unidades y áreas.

---

## Stack Tecnológico

* **Frontend:** [Flutter](https://flutter.dev/) & [Dart](https://dart.dev/) (`^3.13.3`) — Material Design 3
* **Arquitectura:** MVVM (*Model - View - ViewModel*) con `ChangeNotifier`
* **Reconocimiento de Voz:** [`speech_to_text`](https://pub.dev/packages/speech_to_text) (`^7.3.0`)
* **Cliente HTTP:** [`http`](https://pub.dev/packages/http) (`^1.2.0`)
* **Backend consumido:** API REST (`https://localhost:44324/api`)
* **Entorno de Desarrollo:** Docker & VS Code Dev Containers (`.devcontainer`)

---

## Estructura del Proyecto

```text
├── .agents/
│   ├── rules/                 # Reglas del workspace para agentes de IA
│   └── skills/                # Skills de arquitectura MVVM, API REST, Voz y UI Theme
├── .devcontainer/             # Configuración de contenedor de desarrollo (Docker + VS Code)
├── docs/
│   └── DEVELOPMENT.md         # Guía detallada de instalación, Docker y troubleshooting
├── lib/
│   ├── main.dart              # Punto de entrada de la aplicación
│   ├── models/                # Modelos de datos (Usuario, Producto, Inventario, Combos)
│   ├── services/              # Clientes HTTP para consumo de la API REST
│   ├── theme/                 # Sistema de diseño (AppColors, AppTextStyles, AppTheme)
│   ├── viewmodels/            # Gestión de estado y lógica de negocio (ChangeNotifier)
│   └── views/                 # Pantallas de interfaz de usuario
└── pubspec.yaml               # Dependencias y configuración del paquete Flutter
```

---

## Inicio Rápido (Quick Start)

1. Abre el proyecto en **Visual Studio Code**.
2. Presiona `F1` y ejecuta **`Dev Containers: Reopen in Container`**.
3. En la terminal integrada del contenedor, levanta el servidor de desarrollo:
   ```bash
   make dev
   ```
4. Abre **[http://localhost:8080](http://localhost:8080)** en tu navegador.

### Comandos disponibles (`Makefile`)

| Comando | Descripción | Equivalente Flutter |
| :--- | :--- | :--- |
| `make dev` | Levanta el servidor web en `0.0.0.0:8080` | `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080` |
| `make install` | Descarga las dependencias del proyecto | `flutter pub get` |
| `make lint` | Ejecuta el analizador estático de código | `flutter analyze` |
| `make test` | Ejecuta los tests del proyecto | `flutter test` |
| `make build` | Compila la aplicación para Web (producción) | `flutter build web` |
| `make clean` | Limpia la caché de compilación | `flutter clean` |

📖 **¿Primera vez configurando el proyecto?** Revisa la **[Guía Completa de Desarrollo y Docker (`docs/DEVELOPMENT.md`)](./docs/DEVELOPMENT.md)** para ver los requisitos previos, detalles de volúmenes, sincronización de permisos (`UID/GID`) y solución de problemas.
