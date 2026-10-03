import 'package:flutter/material.dart';
import '../models/combos.dart';
import '../services/combos_service.dart';
import '../services/producto_service.dart';

class NuevoProductoViewModel with ChangeNotifier {
  List<Combos> unidades = [];
  List<Combos> areas = [];

  bool cargando = false;
  bool guardando = false;

  Future<void> cargarCombos() async {
    cargando = true;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        ComboService.obtenerUnidades(),
        ComboService.obtenerAreas(),
      ]);

      unidades = resultados[0];
      areas = resultados[1];
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<String?> guardarProducto({
    required String nombre,
    required String codUnidad,
    required String codArea,
    required int stock,
  }) async {
    guardando = true;
    notifyListeners();

    try {
      return await ProductoService.registrarProducto(
        codProducto: '',
        dscProducto: nombre,
        codUnidad: codUnidad,
        codArea: codArea,
        ctdStock: stock,
      );
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}