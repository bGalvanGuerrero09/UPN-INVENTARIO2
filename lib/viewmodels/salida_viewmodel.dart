import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/inventario_service.dart';

class SalidaViewModel with ChangeNotifier {
  // =========================================================
  // PRODUCTO SELECCIONADO
  // =========================================================

  Producto? _productoSeleccionado;

  Producto? get productoSeleccionado =>
      _productoSeleccionado;

  // =========================================================
  // ESTADO
  // =========================================================

  bool _registrando = false;

  bool get registrando => _registrando;

  // =========================================================
  // SELECCIONAR PRODUCTO
  // =========================================================

  void seleccionarProducto(
      Producto producto,
      ) {
    _productoSeleccionado = producto;

    notifyListeners();
  }

  // =========================================================
  // BUSCAR PRODUCTOS
  // =========================================================

  Future<List<Producto>> buscarProductos(
      String texto,
      ) async {
    return await InventarioService
        .filtrarProductos(
      texto,
    );
  }

  // =========================================================
  // BUSCAR Y SELECCIONAR PRODUCTO
  //
  // Se utiliza principalmente para la búsqueda por voz.
  // Busca coincidencia exacta por código o nombre.
  // Si no existe coincidencia exacta, selecciona el primero.
  // =========================================================

  Future<bool> buscarYSeleccionarProducto(
      String texto,
      ) async {
    final productos =
    await InventarioService
        .filtrarProductos(
      texto,
    );

    if (productos.isEmpty) {
      return false;
    }

    final busqueda =
    texto.trim().toLowerCase();

    Producto? exacto;

    for (final producto in productos) {
      if (producto.codProducto
          .trim()
          .toLowerCase() ==
          busqueda ||
          producto.nombre
              .trim()
              .toLowerCase() ==
              busqueda) {
        exacto = producto;

        break;
      }
    }

    seleccionarProducto(
      exacto ?? productos.first,
    );

    return true;
  }

  // =========================================================
  // REGISTRAR SALIDA
  // =========================================================

  Future<bool> registrarSalida(
      int cantidad,
      String codUsuario,
      ) async {
    if (_productoSeleccionado == null) {
      return false;
    }

    // =======================================================
    // VALIDAR CANTIDAD
    // =======================================================

    if (cantidad <= 0) {
      return false;
    }

    // =======================================================
    // VALIDAR STOCK
    // =======================================================

    if (cantidad >
        _productoSeleccionado!.stock) {
      return false;
    }

    // =======================================================
    // INICIAR REGISTRO
    // =======================================================

    _registrando = true;

    notifyListeners();

    try {
      final resultado =
      await InventarioService
          .registrarSalida(
        _productoSeleccionado!,
        cantidad,
        codUsuario,
      );

      // =====================================================
      // ACTUALIZAR STOCK LOCAL
      // =====================================================

      if (resultado) {
        final producto =
        _productoSeleccionado!;

        _productoSeleccionado =
            Producto(
              codProducto:
              producto.codProducto,
              nombre:
              producto.nombre,
              codUnidad:
              producto.codUnidad,
              dscUnidad:
              producto.dscUnidad,
              codArea:
              producto.codArea,
              dscArea:
              producto.dscArea,
              ubicacion:
              producto.ubicacion,
              stock:
              producto.stock -
                  cantidad,
            );
      }

      return resultado;
    } finally {
      _registrando = false;

      notifyListeners();
    }
  }

  // =========================================================
  // LIMPIAR PRODUCTO
  // =========================================================

  void limpiarProducto() {
    _productoSeleccionado = null;

    notifyListeners();
  }
}