import 'package:flutter/material.dart';
import 'ingreso.dart';
import 'salida.dart';
import 'buscar.dart';
import 'nuevo_producto.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El color de fondo viene de app_theme.dart
      appBar: AppBar(
        title: const Text(
          'Inventario',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            // =========================
            // TÍTULO
            // =========================

            const Text(
              '¿Qué deseas hacer?',
              style: AppTextStyles.title,
            ),

            const SizedBox(height: 8),

            const Text(
              'Selecciona una opción para continuar',
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 30),

            // =========================
            // REGISTRAR INGRESO
            // =========================

            _MenuButton(
              title: 'Registrar ingreso',
              icon: Icons.arrow_downward,
              color: AppColors.ingreso,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Ingreso(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // =========================
            // REGISTRAR SALIDA
            // =========================

            _MenuButton(
              title: 'Registrar salida',
              icon: Icons.arrow_upward,
              color: AppColors.salida,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Salida(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // =========================
            // BUSCAR PRODUCTOS
            // =========================

            _MenuButton(
              title: 'Buscar productos',
              icon: Icons.inventory,
              color: AppColors.buscar,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Buscar(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // =========================
            // NUEVO PRODUCTO
            // ==========================0=

            _MenuButton(
              title: 'Nuevo producto',
              icon: Icons.add_box,
              color: AppColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NuevoProducto(),
                  ),
                );
              },

            ),
          ],
        ),
      ),
    );
  }
}


// ======================================================
// BOTÓN DEL MENÚ
// ======================================================

class _MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 90,

      child: ElevatedButton.icon(
        onPressed: onPressed,

        icon: Icon(
          icon,
          size: 32,
        ),

        label: Text(
          title,
          style: AppTextStyles.menuButton,
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
        ),
      ),
    );
  }
}
