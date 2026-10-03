import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/inventario_service.dart';

class IngresoViewModel with ChangeNotifier {
  Producto? _productoSeleccionado;
  bool _registrando = false;

  Producto? get productoSeleccionado =>
      _productoSeleccionado;

  bool get registrando => _registrando;

  void seleccionarProducto(Producto producto) {
    _productoSeleccionado = producto;
    notifyListeners();
  }

  Future<List<Producto>> buscarProductos(
      String texto,
      ) async {
    return await InventarioService.filtrarProductos(
      texto,
    );
  }

  Future<bool> registrarIngreso(
      int cantidad,
      String codUsuario,
      ) async {
    if (_productoSeleccionado == null) {
      return false;
    }

    _registrando = true;
    notifyListeners();

    try {
      final resultado =
      await InventarioService.registrarIngreso(
        _productoSeleccionado!,
        cantidad,
        codUsuario,
      );

      if (resultado) {
        final producto = _productoSeleccionado!;

        _productoSeleccionado = Producto(
          codProducto: producto.codProducto,
          nombre: producto.nombre,
          codUnidad: producto.codUnidad,
          dscUnidad: producto.dscUnidad,
          codArea: producto.codArea,
          dscArea: producto.dscArea,
          ubicacion: producto.ubicacion,
          stock: producto.stock + cantidad,
        );
      }

      return resultado;
    } finally {
      _registrando = false;
      notifyListeners();
    }
  }
}