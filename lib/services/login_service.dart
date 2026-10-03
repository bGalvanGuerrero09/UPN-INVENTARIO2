import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class LoginService {
  final String baseUrl = 'https://localhost:44324/api';

  Future<Usuario?> loginUsuario(String codUsuario, String dscClave) async {
    try {
      final url = Uri.parse('$baseUrl/Logueo/LogueoUsuario/$codUsuario/$dscClave');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['response'] != null) {
          final Map<String, dynamic> userData = jsonResponse['response'];
          String nombreUsuario = userData['dsc_usuario'] ?? '';

          // Validación estricta: Si el nombre está vacío, el usuario no existe o la clave falló
          if (nombreUsuario.trim().isNotEmpty) {
            return Usuario.fromJson(userData);
          }
        }
        return null; // Credenciales incorrectas
      } else {
        return null;
      }
    } catch (e) {
      print('Error en el servicio de login: $e');
      throw Exception('No se pudo conectar con el servidor');
    }
  }
}