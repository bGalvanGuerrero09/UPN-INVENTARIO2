import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/combos.dart';

class ComboService {
  static const String baseUrl =
      'https://localhost:44324/api';

  static Future<List<Combos>> obtenerTipos() async {
    try {
      final url =
      Uri.parse('$baseUrl/Combos/ListarTipo');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> lista =
            data['response'] ?? [];

        return lista
            .map((item) => Combos.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error obtenerTipos: $e');
      return [];
    }
  }

  static Future<List<Combos>> obtenerUnidades() async {
    try {
      final url =
      Uri.parse('$baseUrl/Combos/ListarUnidad');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> lista =
            data['response'] ?? [];

        return lista
            .map((item) => Combos.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error obtenerUnidades: $e');
      return [];
    }
  }

  static Future<List<Combos>> obtenerAreas() async {
    try {
      final url =
      Uri.parse('$baseUrl/Combos/ListarArea');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> lista =
            data['response'] ?? [];

        return lista
            .map((item) => Combos.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error obtenerAreas: $e');
      return [];
    }
  }

  // =============================================================
  // USUARIOS
  // =============================================================

  static Future<List<Combos>> obtenerUsuarios() async {
    try {
      final url =
      Uri.parse('$baseUrl/Combos/ListarUsuario');

      final response = await http.get(url);

      print('================================');
      print('URL USUARIOS: $url');
      print('STATUS USUARIOS: ${response.statusCode}');
      print('RESPONSE USUARIOS: ${response.body}');
      print('================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> lista =
            data['response'] ?? [];

        print(
          'TOTAL USUARIOS: ${lista.length}',
        );

        for (final item in lista) {
          print(
            'USUARIO: ${item['codvar']} - ${item['desvar1']}',
          );
        }

        return lista
            .map((item) => Combos.fromJson(item))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error obtenerUsuarios: $e');
      return [];
    }
  }
}