import 'package:flutter/material.dart';
import 'home.dart';
import '../viewmodels/login_viewmodel.dart';
import '../models/usuario.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // =========================
  // CONTROLADORES
  // =========================

  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController claveController = TextEditingController();

  // =========================
  // VIEW MODEL
  // =========================

  final LoginViewModel _viewModel = LoginViewModel();

  // Mostrar / ocultar contraseña
  bool ocultarClave = true;

  @override
  void initState() {
    super.initState();

    // Escuchamos los cambios del ViewModel
    _viewModel.addListener(_actualizarVista);
  }

  // =========================
  // ACTUALIZAR VISTA
  // =========================

  void _actualizarVista() {
    if (mounted) {
      setState(() {});
    }
  }

  // =========================
  // INICIAR SESIÓN
  // =========================

  Future<void> iniciarSesion() async {
    String usuario = usuarioController.text.trim();
    String clave = claveController.text.trim();

    // Validar campos
    if (usuario.isEmpty || clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los campos',
          ),
          backgroundColor: AppColors.salida,
        ),
      );
      return;
    }

    try {
      // La View llama al ViewModel.
      // El ViewModel se encarga de llamar al LoginService.
      final loginCorrecto = await _viewModel.iniciarSesion(
        usuario,
        clave,
      );

      if (!mounted) return;

      if (loginCorrecto) {
        // Obtenemos el usuario desde el ViewModel
        final Usuario? usuarioLogueado =
            _viewModel.usuarioLogueado;

        if (usuarioLogueado != null) {
          // Ir al menú principal pasando el usuario logueado
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                usuario: usuarioLogueado,
              ),
            ),
          );
        }
      } else {
        // Credenciales incorrectas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Usuario o contraseña incorrectos',
            ),
            backgroundColor: AppColors.salida,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error de conexión con el servidor',
          ),
          backgroundColor: AppColors.salida,
        ),
      );
    }
  }

  // =========================
  // DISEÑO
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              // =========================
              // LOGO
              // =========================
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: AppColors.white,
                  size: 45,
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // TÍTULO
              // =========================
              const Text(
                'Bienvenido',
                style: AppTextStyles.title,
              ),

              const SizedBox(height: 8),

              const Text(
                'Sistema de Inventario',
                style: AppTextStyles.subtitle,
              ),

              const SizedBox(height: 35),

              // =========================
              // USUARIO
              // =========================
              TextField(
                controller: usuarioController,
                enabled: !_viewModel.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Ingrese su usuario',
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // CONTRASEÑA
              // =========================
              TextField(
                controller: claveController,
                enabled: !_viewModel.isLoading,
                obscureText: ocultarClave,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingrese su contraseña',
                  prefixIcon: const Icon(
                    Icons.lock,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ocultarClave
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        ocultarClave = !ocultarClave;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // BOTÓN ENTRAR
              // =========================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading
                      ? null
                      : iniciarSesion,
                  child: _viewModel.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'ENTRAR',
                    style: AppTextStyles.button,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // PIE DE PÁGINA
              // =========================
              const Text(
                '© 2026 Sistema de Inventario',
                style: AppTextStyles.small,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // LIBERAR CONTROLADORES
  // =========================

  @override
  void dispose() {
    _viewModel.removeListener(_actualizarVista);
    _viewModel.dispose();

    usuarioController.dispose();
    claveController.dispose();

    super.dispose();
  }
}