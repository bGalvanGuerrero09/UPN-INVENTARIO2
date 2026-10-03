import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/combos.dart';
import '../viewmodels/nuevo_producto_viewmodel.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NuevoProducto extends StatefulWidget {
  const NuevoProducto({super.key});

  @override
  State<NuevoProducto> createState() => _NuevoProductoState();
}

class _NuevoProductoState extends State<NuevoProducto> {
  // =========================================================
  // VIEW MODEL
  // =========================================================

  final NuevoProductoViewModel _viewModel =
  NuevoProductoViewModel();

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController nombreController =
  TextEditingController();

  final TextEditingController stockController =
  TextEditingController();

  // =========================================================
  // VALORES SELECCIONADOS
  // =========================================================

  String? codUnidad;
  String? codArea;

  // =========================================================
  // INICIALIZACIÓN
  // =========================================================

  @override
  void initState() {
    super.initState();

    // Escuchar cambios del ViewModel
    _viewModel.addListener(_actualizarVista);

    cargarCombos();
  }

  // =========================================================
  // ACTUALIZAR VISTA
  // =========================================================

  void _actualizarVista() {
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // CARGAR COMBOS
  // =========================================================

  Future<void> cargarCombos() async {
    try {
      await _viewModel.cargarCombos();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar los datos: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // GUARDAR PRODUCTO
  // =========================================================

  Future<void> guardarProducto() async {
    final nombre =
    nombreController.text.trim();

    // =======================================================
    // VALIDAR NOMBRE
    // =======================================================

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingrese el nombre del producto',
          ),
        ),
      );

      return;
    }

    // =======================================================
    // VALIDAR UNIDAD
    // =======================================================

    if (codUnidad == null ||
        codUnidad!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seleccione una unidad',
          ),
        ),
      );

      return;
    }

    // =======================================================
    // VALIDAR ÁREA
    // =======================================================

    if (codArea == null ||
        codArea!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seleccione un área',
          ),
        ),
      );

      return;
    }

    // =======================================================
    // VALIDAR STOCK
    // =======================================================

    final stockTexto =
    stockController.text.trim();

    if (stockTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingrese el stock inicial',
          ),
        ),
      );

      return;
    }

    final int? stock =
    int.tryParse(stockTexto);

    if (stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingrese un stock válido',
          ),
        ),
      );

      return;
    }

    // =======================================================
    // GUARDAR UTILIZANDO EL VIEW MODEL
    // =======================================================

    try {
      final resultado =
      await _viewModel.guardarProducto(
        nombre: nombre,
        codUnidad: codUnidad!,
        codArea: codArea!,
        stock: stock,
      );

      if (!mounted) return;

      // =====================================================
      // PRODUCTO REGISTRADO
      // =====================================================

      if (resultado != null) {
        await mostrarProductoGuardado(
          resultado,
          nombre,
          stock,
        );

        if (!mounted) return;

        // Limpiar controles
        nombreController.clear();
        stockController.clear();

        setState(() {
          codUnidad = null;
          codArea = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo registrar el producto',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al registrar el producto: $e',
          ),
        ),
      );
    }
  }

  // =========================================================
  // MOSTRAR PRODUCTO GUARDADO
  // =========================================================

  Future<void> mostrarProductoGuardado(
      String codigo,
      String nombre,
      int stock,
      ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(25),
          ),
          child: Padding(
            padding:
            const EdgeInsets.all(28),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                // =================================================
                // ICONO
                // =================================================

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 70,
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // TÍTULO
                // =================================================

                const Text(
                  '¡PRODUCTO GUARDADO!',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                    FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'El producto se registró correctamente',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // INFORMACIÓN DEL PRODUCTO
                // =================================================

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                    Colors.grey.shade100,
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Text(
                        nombre,
                        textAlign:
                        TextAlign.center,
                        style:
                        const TextStyle(
                          fontSize: 19,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        'Código: $codigo',
                        style:
                        const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        'Stock inicial: $stock',
                        style:
                        const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =================================================
                // CONTINUAR
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.green,
                      foregroundColor:
                      Colors.white,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child: const Text(
                      'CONTINUAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // LIBERAR RECURSOS
  // =========================================================

  @override
  void dispose() {
    _viewModel.removeListener(
      _actualizarVista,
    );

    _viewModel.dispose();

    nombreController.dispose();
    stockController.dispose();

    super.dispose();
  }

  // =========================================================
  // INTERFAZ
  // =========================================================

  @override
  Widget build(BuildContext context) {
    // =========================================================
    // DATOS DEL VIEW MODEL
    // =========================================================

    final List<Combos> unidades =
        _viewModel.unidades;

    final List<Combos> areas =
        _viewModel.areas;

    final bool cargando =
        _viewModel.cargando;

    final bool guardando =
        _viewModel.guardando;

    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Nuevo Producto'),
        backgroundColor:
        AppColors.primary,
        foregroundColor:
        Colors.white,
      ),

      body: cargando
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar producto',
              style:
              AppTextStyles.title,
            ),

            const SizedBox(height: 20),

            // =================================================
            // NOMBRE
            // =================================================

            TextField(
              controller:
              nombreController,
              enabled: !guardando,
              textCapitalization:
              TextCapitalization
                  .sentences,
              decoration:
              const InputDecoration(
                labelText:
                'Nombre del producto',
                hintText:
                'Ingrese el nombre del producto',
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(
                  Icons.inventory_2,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // UNIDAD
            // =================================================

            DropdownButtonFormField<
                String>(
              value: codUnidad,
              decoration:
              const InputDecoration(
                labelText: 'Unidad',
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(
                  Icons.straighten,
                ),
              ),
              items:
              unidades.map((unidad) {
                return DropdownMenuItem<
                    String>(
                  value:
                  unidad.codvar,
                  child: Text(
                    unidad.desvar1,
                  ),
                );
              }).toList(),
              onChanged: guardando
                  ? null
                  : (value) {
                setState(() {
                  codUnidad =
                      value;
                });
              },
            ),

            const SizedBox(height: 20),

            // =================================================
            // ÁREA
            // =================================================

            DropdownButtonFormField<
                String>(
              value: codArea,
              decoration:
              const InputDecoration(
                labelText: 'Área',
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(
                  Icons.location_on,
                ),
              ),
              items:
              areas.map((area) {
                return DropdownMenuItem<
                    String>(
                  value:
                  area.codvar,
                  child: Text(
                    area.desvar1,
                  ),
                );
              }).toList(),
              onChanged: guardando
                  ? null
                  : (value) {
                setState(() {
                  codArea =
                      value;
                });
              },
            ),

            const SizedBox(height: 20),

            // =================================================
            // STOCK
            // =================================================

            TextField(
              controller:
              stockController,
              enabled: !guardando,
              keyboardType:
              TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter
                    .digitsOnly,
              ],
              decoration:
              const InputDecoration(
                labelText:
                'Stock inicial',
                hintText:
                'Ingrese la cantidad',
                border:
                OutlineInputBorder(),
                prefixIcon:
                Icon(
                  Icons.inventory,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // GUARDAR
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,
              child:
              ElevatedButton.icon(
                onPressed: guardando
                    ? null
                    : guardarProducto,
                icon: guardando
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                    Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.save,
                ),
                label: Text(
                  guardando
                      ? 'Guardando...'
                      : 'Guardar Producto',
                ),
                style: ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  AppColors.primary,
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
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