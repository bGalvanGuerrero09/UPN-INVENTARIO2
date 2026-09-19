import 'package:flutter/material.dart';

import '../services/inventario_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NuevoProducto extends StatefulWidget {
  const NuevoProducto({super.key});

  @override
  State<NuevoProducto> createState() => _NuevoProductoState();
}

class _NuevoProductoState extends State<NuevoProducto> {
  // =====================================================
  // CONTROLADORES
  // =====================================================

  final TextEditingController nombreController =
  TextEditingController();

  final TextEditingController stockController =
  TextEditingController();

  // =====================================================
  // GUARDAR PRODUCTO
  // =====================================================

  void guardarProducto() {
    final nombre = nombreController.text.trim();
    final stockTexto = stockController.text.trim();

    // -----------------------------------------------------
    // VALIDAR NOMBRE
    // -----------------------------------------------------

    if (nombre.isEmpty) {
      mostrarMensaje(
        'Ingrese el nombre del producto',
        esError: true,
      );

      return;
    }

    // -----------------------------------------------------
    // VALIDAR STOCK
    // -----------------------------------------------------

    if (stockTexto.isEmpty) {
      mostrarMensaje(
        'Ingrese el stock inicial',
        esError: true,
      );

      return;
    }

    final stock = int.tryParse(stockTexto);

    if (stock == null || stock < 0) {
      mostrarMensaje(
        'El stock debe ser un número válido',
        esError: true,
      );

      return;
    }

    // -----------------------------------------------------
    // VERIFICAR SI YA EXISTE
    // -----------------------------------------------------

    final productoExistente =
    InventarioService.buscarProducto(nombre);

    if (productoExistente != null) {
      mostrarMensaje(
        'El producto ya existe',
        esError: true,
      );

      return;
    }

    // -----------------------------------------------------
    // CREAR PRODUCTO
    // -----------------------------------------------------

    final producto = InventarioService.agregarProducto(
      nombre,
      stock,
    );

    // -----------------------------------------------------
    // MOSTRAR CONFIRMACIÓN
    // -----------------------------------------------------

    mostrarMensaje(
      'Producto "${producto.nombre}" registrado correctamente',
      esError: false,
    );

    // -----------------------------------------------------
    // VOLVER AL HOME
    // -----------------------------------------------------

    Future.delayed(
      const Duration(milliseconds: 800),
          () {
        if (!mounted) return;

        Navigator.pop(context);
      },
    );
  }

  // =====================================================
  // MENSAJE
  // =====================================================

  void mostrarMensaje(
      String mensaje, {
        required bool esError,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
        esError ? AppColors.error : AppColors.success,
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    nombreController.dispose();
    stockController.dispose();

    super.dispose();
  }

  // =====================================================
  // INTERFAZ
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nuevo producto',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            // =================================================
            // TÍTULO
            // =================================================

            const Text(
              'Registrar producto',
              style: AppTextStyles.title,
            ),

            const SizedBox(height: 8),

            const Text(
              'Ingrese la información del nuevo producto.',
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 30),

            // =================================================
            // NOMBRE
            // =================================================

            const Text(
              'Nombre del producto',
              style: AppTextStyles.label,
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nombreController,

              textCapitalization:
              TextCapitalization.sentences,

              decoration: InputDecoration(
                hintText: 'Ej. Paracetamol 500 mg',

                prefixIcon: const Icon(
                  Icons.inventory_2,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // STOCK INICIAL
            // =================================================

            const Text(
              'Stock inicial',
              style: AppTextStyles.label,
            ),

            const SizedBox(height: 8),

            TextField(
              controller: stockController,

              keyboardType:
              TextInputType.number,

              decoration: InputDecoration(
                hintText: 'Ej. 100',

                prefixIcon: const Icon(
                  Icons.numbers,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // =================================================
            // INFORMACIÓN
            // =================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.08),

                borderRadius:
                BorderRadius.circular(15),
              ),

              child: const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'El stock inicial representa la cantidad disponible al momento de registrar el producto.',
                      style: AppTextStyles.small,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // BOTÓN GUARDAR
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: guardarProducto,

                icon: const Icon(
                  Icons.save,
                ),

                label: const Text(
                  'Registrar producto',
                  style: AppTextStyles.button,
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,

                  foregroundColor:
                  AppColors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
