import 'package:flutter/material.dart';
import 'home.dart';
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

  final TextEditingController usuarioController =
  TextEditingController();

  final TextEditingController claveController =
  TextEditingController();

  // Mostrar / ocultar contraseña
  bool ocultarClave = true;

  // =========================
  // INICIAR SESIÓN
  // =========================

  void iniciarSesion() {
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

    // Ir al menú principal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Home(),
      ),
    );
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
                  onPressed: iniciarSesion,

                  child: const Text(
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
    usuarioController.dispose();
    claveController.dispose();

    super.dispose();
  }
}
