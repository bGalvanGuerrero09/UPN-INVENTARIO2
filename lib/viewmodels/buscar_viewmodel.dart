import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class BuscarViewModel with ChangeNotifier {
  List<Producto> _productos = [];
  bool _cargando = false;

  List<Producto> get productos => _productos;
  bool get cargando => _cargando;

  Future<void> cargarProductos() async {
    _cargando = true;
    notifyListeners();

    try {
      _productos =
      await ProductoService.obtenerProductos();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> filtrar(String texto) async {
    _productos =
    await ProductoService.filtrarProductos(texto);

    notifyListeners();
  }
}