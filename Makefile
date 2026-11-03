.PHONY: help dev start install lint test build clean

PORT ?= 8080
HOST ?= 0.0.0.0
CONTAINER ?= upn-inventario2-app

# Si estamos dentro del contenedor (/.dockerenv existe), ejecuta directo;
# si estamos fuera (en WSL/Host), lo ejecuta dentro del contenedor Docker.
ifeq ($(wildcard /.dockerenv),)
	RUN = docker exec -it $(CONTAINER) zsh -ic
else
	RUN =
endif

help: ## Muestra los comandos disponibles
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

dev: ## Levanta el servidor de desarrollo Flutter Web (http://localhost:8080)
ifdef RUN
	$(RUN) "flutter run -d web-server --web-hostname $(HOST) --web-port $(PORT)"
else
	flutter run -d web-server --web-hostname $(HOST) --web-port $(PORT)
endif

start: dev ## Alias de 'make dev'

install: ## Descarga e instala las dependencias de pubspec.yaml
ifdef RUN
	$(RUN) "flutter pub get"
else
	flutter pub get
endif

lint: ## Analiza el código en busca de errores o advertencias
ifdef RUN
	$(RUN) "flutter analyze"
else
	flutter analyze
endif

test: ## Ejecuta las pruebas unitarias y de widgets
ifdef RUN
	$(RUN) "flutter test"
else
	flutter test
endif

build: ## Compila la versión de producción para Web
ifdef RUN
	$(RUN) "flutter build web"
else
	flutter build web
endif

clean: ## Limpia los archivos generados de compilación
ifdef RUN
	$(RUN) "flutter clean"
else
	flutter clean
endif
