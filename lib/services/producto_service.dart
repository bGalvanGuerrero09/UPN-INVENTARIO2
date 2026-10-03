import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/producto.dart';

class ProductoService {
  static const String baseUrl = 'https://localhost:44324/api';

  // =========================================================
  // REGISTRAR PRODUCTO
  // =========================================================

  static Future<String?> registrarProducto({
    required String codProducto,
    required String dscProducto,
    required String codUnidad,
    required String codArea,
    required int ctdStock,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/Producto/InsertarProducto',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cod_producto': codProducto,
          'dsc_producto': dscProducto,
          'cod_unidad': codUnidad,
          'cod_area': codArea,
          'ctd_stock': ctdStock,
        }),
      );

      print('================================');
      print('STATUS PRODUCTO: ${response.statusCode}');
      print('RESPONSE PRODUCTO: ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data['cod_producto']?.toString();
      }

      return null;
    } catch (e) {
      print('Error registrarProducto: $e');
      return null;
    }
  }

  // =========================================================
  // LISTAR PRODUCTOS
  // =========================================================

  static Future<List<Producto>> obtenerProductos() async {
    try {
      final url = Uri.parse(
        '$baseUrl/Producto/ListarProducto',
      );

      final response = await http.get(url);

      print('================================');
      print('STATUS LISTAR PRODUCTOS: ${response.statusCode}');
      print('RESPONSE LISTAR PRODUCTOS: ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> lista =
            data['response'] ?? [];

        return lista
            .map(
              (item) => Producto.fromJson(item),
        )
            .toList();
      }

      return [];
    } catch (e) {
      print('Error obtenerProductos: $e');
      return [];
    }
  }

  // =========================================================
  // FILTRAR PRODUCTOS
  // =========================================================

  static Future<List<Producto>> filtrarProductos(
      String texto,
      ) async {
    try {
      final productos = await obtenerProductos();

      if (texto.trim().isEmpty) {
        return productos;
      }

      final busqueda = texto
          .trim()
          .toLowerCase();

      return productos.where((producto) {
        return producto.nombre
            .toLowerCase()
            .contains(busqueda) ||
            producto.codProducto
                .toLowerCase()
                .contains(busqueda) ||
            producto.dscUnidad
                .toLowerCase()
                .contains(busqueda) ||
            producto.dscArea
                .toLowerCase()
                .contains(busqueda);
      }).toList();
    } catch (e) {
      print('Error filtrarProductos: $e');
      return [];
    }
  }
}