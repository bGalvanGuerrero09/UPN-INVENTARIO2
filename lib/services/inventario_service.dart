import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../models/inventario.dart';

class InventarioService {
  static const String baseUrl =
      'https://localhost:44324/api';

  // =============================================================
  // REGISTRAR INGRESO
  // =============================================================

  static Future<bool> registrarIngreso(
      Producto producto,
      int cantidad,
      String codUsuario,
      ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/Inventario/InsertarInventario',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'num_inventario': 0,
          'cod_producto': producto.codProducto,
          'cod_tipo_movimiento': 'ING',
          'ctd_movimiento': cantidad,
          'cod_usuario': codUsuario,
        }),
      );

      print('================================');
      print('URL INGRESO: $url');
      print('COD USUARIO: $codUsuario');
      print('STATUS INGRESO: ${response.statusCode}');
      print('RESPONSE INGRESO: ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error registrarIngreso: $e');
      return false;
    }
  }

  // =============================================================
  // REGISTRAR SALIDA
  // =============================================================

  static Future<bool> registrarSalida(
      Producto producto,
      int cantidad,
      String codUsuario,
      ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/Inventario/InsertarInventario',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'num_inventario': 0,
          'cod_producto': producto.codProducto,
          'cod_tipo_movimiento': 'SAL',
          'ctd_movimiento': cantidad,
          'cod_usuario': codUsuario,
        }),
      );

      print('================================');
      print('URL SALIDA: $url');
      print('COD USUARIO: $codUsuario');
      print('STATUS SALIDA: ${response.statusCode}');
      print('RESPONSE SALIDA: ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error registrarSalida: $e');
      return false;
    }
  }

  // =============================================================
  // LISTAR PRODUCTOS
  // =============================================================

  static Future<List<Producto>> obtenerProductos() async {
    try {
      final url = Uri.parse(
        '$baseUrl/Producto/ListarProducto',
      );

      final response = await http.get(url);

      print('================================');
      print('STATUS PRODUCTOS: ${response.statusCode}');
      print('RESPONSE PRODUCTOS: ${response.body}');
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

  // =============================================================
  // BUSCAR PRODUCTO
  // =============================================================

  static Future<Producto?> buscarProducto(
      String codProducto,
      ) async {
    try {
      final productos = await obtenerProductos();

      for (final producto in productos) {
        if (producto.codProducto == codProducto) {
          return producto;
        }
      }

      return null;
    } catch (e) {
      print('Error buscarProducto: $e');
      return null;
    }
  }

  // =============================================================
  // FILTRAR PRODUCTOS
  // =============================================================

  static Future<List<Producto>> filtrarProductos(
      String texto,
      ) async {
    try {
      final productos = await obtenerProductos();

      if (texto.trim().isEmpty) {
        return productos;
      }

      final busqueda =
      texto.trim().toLowerCase();

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

  // =============================================================
  // LISTAR TODOS LOS MOVIMIENTOS
  // =============================================================

  static Future<List<Inventario>> obtenerMovimientos() async {
    try {
      final url = Uri.parse(
        '$baseUrl/Inventario/ListarInventario',
      );

      final response = await http.get(url);

      print('================================');
      print('STATUS MOVIMIENTOS: ${response.statusCode}');
      print('RESPONSE MOVIMIENTOS: ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> lista =
            data['response'] ?? [];

        return lista
            .map(
              (item) => Inventario.fromJson(item),
        )
            .toList();
      }

      return [];
    } catch (e) {
      print('Error obtenerMovimientos: $e');
      return [];
    }
  }

  // =============================================================
  // LISTAR MOVIMIENTOS POR PRODUCTO
  // =============================================================

  static Future<List<Inventario>>
  obtenerMovimientosPorProducto(
      String codProducto,
      ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/Inventario/ListarInventarioxProducto/$codProducto',
      );

      final response = await http.get(url);

      print('================================');
      print('URL MOVIMIENTOS PRODUCTO: $url');
      print(
        'STATUS MOVIMIENTOS PRODUCTO: ${response.statusCode}',
      );
      print(
        'RESPONSE MOVIMIENTOS PRODUCTO: ${response.body}',
      );
      print('================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> lista =
            data['response'] ?? [];

        return lista
            .map(
              (item) => Inventario.fromJson(item),
        )
            .toList();
      }

      return [];
    } catch (e) {
      print(
        'Error obtenerMovimientosPorProducto: $e',
      );
      return [];
    }
  }

  // =============================================================
  // LISTAR MOVIMIENTOS POR USUARIO
  // =============================================================

  static Future<List<Inventario>>
  obtenerMovimientosPorUsuario(
      String codUsuario,
      ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/Inventario/ListarInventarioxUsuario/$codUsuario',
      );

      final response = await http.get(url);

      print('================================');
      print('URL MOVIMIENTOS USUARIO: $url');
      print(
        'COD USUARIO: $codUsuario',
      );
      print(
        'STATUS MOVIMIENTOS USUARIO: ${response.statusCode}',
      );
      print(
        'RESPONSE MOVIMIENTOS USUARIO: ${response.body}',
      );
      print('================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> lista =
            data['response'] ?? [];

        return lista
            .map(
              (item) => Inventario.fromJson(item),
        )
            .toList();
      }

      return [];
    } catch (e) {
      print(
        'Error obtenerMovimientosPorUsuario: $e',
      );
      return [];
    }
  }
}