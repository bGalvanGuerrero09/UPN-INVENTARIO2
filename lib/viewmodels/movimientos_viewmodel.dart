import 'package:flutter/material.dart';

import '../models/inventario.dart';
import '../models/producto.dart';
import '../models/combos.dart';

import '../services/inventario_service.dart';
import '../services/producto_service.dart';
import '../services/combos_service.dart';

class MovimientosViewModel with ChangeNotifier {
  // =========================================================
  // LISTAS
  // =========================================================

  List<Inventario> _todosLosMovimientos = [];
  List<Inventario> _movimientos = [];

  List<Producto> _productos = [];
  List<Combos> _usuarios = [];

  // =========================================================
  // FILTROS
  // =========================================================

  String? _productoSeleccionado;
  String? _usuarioSeleccionado;

  // =========================================================
  // ESTADO
  // =========================================================

  bool _cargando = false;

  // =========================================================
  // GETTERS
  // =========================================================

  List<Inventario> get movimientos => _movimientos;

  List<Producto> get productos => _productos;

  List<Combos> get usuarios => _usuarios;

  String? get productoSeleccionado =>
      _productoSeleccionado;

  String? get usuarioSeleccionado =>
      _usuarioSeleccionado;

  bool get cargando => _cargando;

  // =========================================================
  // CARGAR DATOS
  // =========================================================

  Future<void> cargarDatos({
    String? codUsuario,
  }) async {
    _cargando = true;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        InventarioService.obtenerMovimientos(),
        ProductoService.obtenerProductos(),
        ComboService.obtenerUsuarios(),
      ]);

      _todosLosMovimientos =
      resultados[0] as List<Inventario>;

      _productos =
      resultados[1] as List<Producto>;

      _usuarios =
      resultados[2] as List<Combos>;

      // Si viene un usuario logueado,
      // filtramos inicialmente por ese usuario.
      _usuarioSeleccionado = codUsuario;

      aplicarFiltros();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // =========================================================
  // APLICAR FILTROS
  // =========================================================

  void aplicarFiltros() {
    _movimientos =
        _todosLosMovimientos.where((movimiento) {
          final coincideProducto =
              _productoSeleccionado == null ||
                  _productoSeleccionado!.isEmpty ||
                  movimiento.codProducto ==
                      _productoSeleccionado;

          final coincideUsuario =
              _usuarioSeleccionado == null ||
                  _usuarioSeleccionado!.isEmpty ||
                  movimiento.codUsuario ==
                      _usuarioSeleccionado;

          return coincideProducto &&
              coincideUsuario;
        }).toList();

    notifyListeners();
  }

  // =========================================================
  // SELECCIONAR PRODUCTO
  // =========================================================

  void seleccionarProducto(
      Producto producto,
      ) {
    _productoSeleccionado =
    producto.codProducto.isEmpty
        ? null
        : producto.codProducto;

    aplicarFiltros();
  }

  // =========================================================
  // SELECCIONAR USUARIO
  // =========================================================

  void seleccionarUsuario(
      Combos usuario,
      ) {
    _usuarioSeleccionado =
    usuario.codvar.isEmpty
        ? null
        : usuario.codvar;

    aplicarFiltros();
  }

  // =========================================================
  // LIMPIAR FILTROS
  // =========================================================

  void limpiarFiltros({
    String? codUsuario,
  }) {
    _productoSeleccionado = null;

    // Conservamos al usuario logueado
    _usuarioSeleccionado = codUsuario;

    aplicarFiltros();
  }

  // =========================================================
  // OBTENER PRODUCTO SELECCIONADO
  // =========================================================

  Producto? obtenerProductoSeleccionado() {
    if (_productoSeleccionado == null ||
        _productoSeleccionado!.isEmpty) {
      return null;
    }

    for (final producto in _productos) {
      if (producto.codProducto ==
          _productoSeleccionado) {
        return producto;
      }
    }

    return null;
  }

  // =========================================================
  // OBTENER USUARIO SELECCIONADO
  // =========================================================

  Combos? obtenerUsuarioSeleccionado() {
    if (_usuarioSeleccionado == null ||
        _usuarioSeleccionado!.isEmpty) {
      return null;
    }

    for (final usuario in _usuarios) {
      if (usuario.codvar ==
          _usuarioSeleccionado) {
        return usuario;
      }
    }

    return null;
  }

  // =========================================================
  // TEXTO PRODUCTO
  // =========================================================

  String get textoProducto {
    final producto =
    obtenerProductoSeleccionado();

    if (producto == null) {
      return 'Todos los productos';
    }

    return '${producto.nombre} (${producto.codProducto})';
  }

  // =========================================================
  // TEXTO USUARIO
  // =========================================================

  String get textoUsuario {
    final usuario =
    obtenerUsuarioSeleccionado();

    if (usuario == null) {
      return 'Todos los usuarios';
    }

    return '${usuario.desvar1} (${usuario.codvar})';
  }

  // =========================================================
  // FORMATEAR FECHA
  // =========================================================

  String formatearFecha(DateTime fecha) {
    final dia =
    fecha.day.toString().padLeft(2, '0');

    final mes =
    fecha.month.toString().padLeft(2, '0');

    final anio =
    fecha.year.toString();

    final hora =
    fecha.hour.toString().padLeft(2, '0');

    final minuto =
    fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio $hora:$minuto';
  }

  // =========================================================
  // FORMATEAR FECHA CORTA
  // =========================================================

  String formatearFechaCorta(
      DateTime fecha,
      ) {
    final dia =
    fecha.day.toString().padLeft(2, '0');

    final mes =
    fecha.month.toString().padLeft(2, '0');

    final hora =
    fecha.hour.toString().padLeft(2, '0');

    final minuto =
    fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes $hora:$minuto';
  }
}