import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/producto.dart';
import '../services/inventario_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class Buscar extends StatefulWidget {
  const Buscar({super.key});

  @override
  State<Buscar> createState() => _BuscarState();
}

class _BuscarState extends State<Buscar> {
  // =========================================================
  // RECONOCIMIENTO DE VOZ
  // =========================================================

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool escuchando = false;
  bool disponible = false;

  // =========================================================
  // BUSCADOR
  // =========================================================

  final TextEditingController busquedaController =
  TextEditingController();

  // Lista que se muestra actualmente
  List<Producto> productosFiltrados = [];

  @override
  void initState() {
    super.initState();

    productosFiltrados =
        InventarioService.obtenerProductos();

    inicializarVoz();
  }

  // =========================================================
  // INICIALIZAR VOZ
  // =========================================================

  Future<void> inicializarVoz() async {
    disponible = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' ||
            status == 'notListening') {
          if (mounted) {
            setState(() {
              escuchando = false;
            });
          }
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            escuchando = false;
          });
        }
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // FILTRAR PRODUCTOS
  // =========================================================

  void filtrar(String texto) {
    setState(() {
      productosFiltrados =
          InventarioService.filtrarProductos(texto);
    });
  }

  // =========================================================
  // BUSCAR POR VOZ
  // =========================================================

  Future<void> buscarPorVoz() async {
    if (!disponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El reconocimiento de voz no está disponible.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (escuchando) {
      await _speech.stop();

      setState(() {
        escuchando = false;
      });

      return;
    }

    setState(() {
      escuchando = true;
    });

    await _speech.listen(
      localeId: 'es-PE',
      onResult: (resultado) {
        final texto = resultado.recognizedWords;

        busquedaController.text = texto;

        // Colocar el cursor al final
        busquedaController.selection =
            TextSelection.fromPosition(
              TextPosition(
                offset: busquedaController.text.length,
              ),
            );

        filtrar(texto);
      },
    );
  }

  // =========================================================
  // MOSTRAR DETALLE DEL PRODUCTO
  // =========================================================

  void mostrarProducto(Producto producto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Información del producto',
            style: AppTextStyles.dialogTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                producto.nombre,
                style: AppTextStyles.productName,
              ),

              const SizedBox(height: 15),

              Text(
                'Código: ${producto.id}',
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 8),

              Text(
                'Stock disponible: ${producto.stock}',
                style: AppTextStyles.body,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    busquedaController.dispose();
    _speech.stop();

    super.dispose();
  }

  // =========================================================
  // INTERFAZ
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        title: const Text(
          'Buscar productos',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            // =================================================
            // TÍTULO
            // =================================================

            const Text(
              'Productos',
              style: AppTextStyles.title,
            ),

            const SizedBox(height: 8),

            const Text(
              'Busca un producto por nombre o utiliza la búsqueda por voz.',
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 25),

            // =================================================
            // BUSCADOR
            // =================================================

            TextField(
              controller: busquedaController,

              onChanged: filtrar,

              decoration: InputDecoration(
                hintText: 'Buscar producto...',

                prefixIcon: const Icon(
                  Icons.search,
                ),

                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BOTÓN LIMPIAR
                    if (busquedaController
                        .text
                        .isNotEmpty)
                      IconButton(
                        onPressed: () {
                          busquedaController.clear();
                          filtrar('');
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      ),

                    // BOTÓN VOZ
                    IconButton(
                      onPressed: buscarPorVoz,
                      icon: Icon(
                        escuchando
                            ? Icons.mic
                            : Icons.mic_none,
                      ),
                      color: escuchando
                          ? Colors.red
                          : AppColors.primary,
                    ),
                  ],
                ),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),

                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),

                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // =================================================
            // INDICADOR DE VOZ
            // =================================================

            if (escuchando)
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color: Colors.red,
                    ),

                    SizedBox(width: 10),

                    Text(
                      'Escuchando...',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            // =================================================
            // CONTADOR
            // =================================================

            Text(
              '${productosFiltrados.length} producto(s) encontrado(s)',
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 10),

            // =================================================
            // TABLA / LISTADO
            // =================================================

            Expanded(
              child: productosFiltrados.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 60,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 15),

                    Text(
                      'No se encontraron productos',
                      style:
                      AppTextStyles.subtitle,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount:
                productosFiltrados.length,

                itemBuilder:
                    (context, index) {
                  final producto =
                  productosFiltrados[
                  index];

                  return _ProductoCard(
                    producto: producto,
                    onTap: () {
                      mostrarProducto(
                        producto,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CARD DEL PRODUCTO
// ============================================================

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const _ProductoCard({
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,

      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(15),
      ),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(15),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Row(
            children: [
              // =================================================
              // ICONO
              // =================================================

              Container(
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  color:
                  Colors.blue.shade50,

                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.medication,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 15),

              // =================================================
              // INFORMACIÓN
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      producto.nombre,
                      style:
                      AppTextStyles.productName,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Código: ${producto.id}',
                      style:
                      AppTextStyles.body,
                    ),
                  ],
                ),
              ),

              // =================================================
              // STOCK
              // =================================================

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,

                children: [
                  const Text(
                    'Stock',
                    style:
                    AppTextStyles.stockLabel,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${producto.stock}',
                    style:
                    AppTextStyles.stockValue,
                  ),
                ],
              ),

              const SizedBox(width: 5),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
