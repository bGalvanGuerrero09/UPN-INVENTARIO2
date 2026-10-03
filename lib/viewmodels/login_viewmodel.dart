import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/login_service.dart';

class LoginViewModel with ChangeNotifier {
  final LoginService _loginService = LoginService();

  bool _isLoading = false;
  Usuario? _usuarioLogueado;

  bool get isLoading => _isLoading;
  Usuario? get usuarioLogueado => _usuarioLogueado;

  Future<bool> iniciarSesion(
      String codUsuario,
      String clave,
      ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _usuarioLogueado = await _loginService.loginUsuario(
        codUsuario,
        clave,
      );

      return _usuarioLogueado != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}