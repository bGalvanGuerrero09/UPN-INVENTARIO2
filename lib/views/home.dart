import 'package:flutter/material.dart';
import 'login.dart';
import '../models/usuario.dart';
import 'ingreso.dart';
import 'salida.dart';
import 'buscar.dart';
import 'nuevo_producto.dart';
import 'movimientos.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class Home extends StatelessWidget {
  final Usuario? usuario;

  const Home({
    super.key,
    this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    String nombreUsuario =
        usuario?.dsc_usuario ?? 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventario',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            Text(
              'Bienvenido',
              style: AppTextStyles.title,
            ),

            const SizedBox(height: 5),

            Text(
              nombreUsuario,
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 30),

            // =================================================
// REGISTRAR INGRESO
// =================================================

            _MenuButton(
              title: 'Registrar ingreso',
              icon: Icons.add_box,
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Ingreso(
                      usuario: usuario,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // =================================================
            // REGISTRAR SALIDA
            // =================================================

            _MenuButton(
              title: 'Registrar salida',
              icon: Icons.remove_circle,
              color: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Salida(
                      usuario: usuario,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // =================================================
            // VER MOVIMIENTOS
            // =================================================

            _MenuButton(
              title: 'Ver movimientos',
              icon: Icons.history,
              color: AppColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Movimientos(
                      usuario: usuario,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // =================================================
            // BUSCAR PRODUCTOS
            // =================================================

            _MenuButton(
              title: 'Buscar productos',
              icon: Icons.search,
              color: Colors.purple,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const Buscar(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // =================================================
            // NUEVO PRODUCTO
            // =================================================

            _MenuButton(
              title: 'Nuevo producto',
              icon: Icons.inventory_2,
              color: Colors.lime,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const NuevoProducto(),
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

// =============================================================
// BOTÓN DEL MENÚ
// =============================================================

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
      height: 65,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 30,
        ),
        label: Text(
          title,
          style: AppTextStyles.button,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}