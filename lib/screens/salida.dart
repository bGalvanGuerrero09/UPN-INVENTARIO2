import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/producto.dart';
import '../services/inventario_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class Salida extends StatefulWidget {
  const Salida({super.key});

  @override
  State<Salida> createState() => _SalidaState();
}

class _SalidaState extends State<Salida> {
  // =========================================================
  // RECONOCIMIENTO DE VOZ
  // =========================================================

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool escuchando = false;
  bool vozDisponible = false;

  // =========================================================
  // CANTIDAD
  // =========================================================

  final TextEditingController cantidadController =
  TextEditingController();

  // =========================================================
  // INFORMACIÓN DE VOZ
  // =========================================================

  String textoVoz = '';

  // =========================================================
  // PRODUCTO SELECCIONADO
  // =========================================================

  Producto? productoSeleccionado;

  // =========================================================
  // INICIALIZACIÓN
  // =========================================================

  @override
  void initState() {
    super.initState();

    inicializarVoz();
  }

  // =========================================================
  // INICIALIZAR VOZ
  // =========================================================

  Future<void> inicializarVoz() async {
    vozDisponible = await _speech.initialize(
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
  // ESCUCHAR CANTIDAD + PRODUCTO
  //
  // Ejemplo:
  //
  // "5 mouse Logitech"
  //
  // =========================================================

  Future<void> escucharSalida() async {
    if (!vozDisponible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El reconocimiento de voz no está disponible.',
          ),
          backgroundColor: AppColors.error,
        ),
      );

      return;
    }

    // Si ya está escuchando, detenemos.
    if (escuchando) {
      await _speech.stop();

      setState(() {
        escuchando = false;
      });

      return;
    }

    setState(() {
      escuchando = true;
      textoVoz = '';
    });

    await _speech.listen(
      localeId: 'es-PE',
      onResult: (resultado) {
        final texto = resultado.recognizedWords;

        setState(() {
          textoVoz = texto;
        });

        procesarTextoVoz(texto);
      },
    );
  }

  // =========================================================
  // PROCESAR VOZ
  //
  // FORMATO:
  //
  // cantidad + producto
  //
  // Ejemplo:
  //
  // "5 mouse Logitech"
  //
  // =========================================================

  void procesarTextoVoz(String texto) {
    if (texto.trim().isEmpty) {
      return;
    }

    final palabras =
    texto.trim().split(RegExp(r'\s+'));

    if (palabras.isEmpty) {
      return;
    }

    // =======================================================
    // PRIMERA PALABRA = CANTIDAD
    // =======================================================

    final cantidadTexto = palabras.first;

    final cantidad = int.tryParse(cantidadTexto);

    if (cantidad == null) {
      return;
    }

    cantidadController.text =
        cantidad.toString();

    // =======================================================
    // RESTO = PRODUCTO
    // =======================================================

    if (palabras.length < 2) {
      return;
    }

    final nombreProducto =
    palabras.sublist(1).join(' ');

    buscarProductoPorTexto(nombreProducto);
  }

  // =========================================================
  // BUSCAR PRODUCTO
  // =========================================================

  void buscarProductoPorTexto(String texto) {
    final productos =
    InventarioService.filtrarProductos(texto);

    if (productos.isEmpty) {
      return;
    }

    // Primero intentamos encontrar coincidencia exacta.
    final exacto =
    InventarioService.buscarProducto(texto);

    setState(() {
      productoSeleccionado =
          exacto ?? productos.first;
    });
  }

  // =========================================================
  // BUSCAR PRODUCTO CON LUPA
  // =========================================================

  void mostrarBusquedaProductos() {
    String busqueda = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final productos =
            InventarioService.filtrarProductos(
              busqueda,
            );

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                    20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Buscar producto',
                    style:
                    AppTextStyles.sectionTitle,
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // BUSCADOR
                  // =================================================

                  TextField(
                    autofocus: true,
                    onChanged: (valor) {
                      setModalState(() {
                        busqueda = valor;
                      });
                    },
                    decoration: InputDecoration(
                      hintText:
                      'Buscar producto...',
                      prefixIcon:
                      const Icon(
                        Icons.search,
                      ),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =================================================
                  // LISTA
                  // =================================================

                  SizedBox(
                    height: 300,
                    child: productos.isEmpty
                        ? const Center(
                      child: Text(
                        'No se encontró el producto.',
                      ),
                    )
                        : ListView.builder(
                      itemCount:
                      productos.length,
                      itemBuilder:
                          (context, index) {
                        final producto =
                        productos[index];

                        return ListTile(
                          leading:
                          const CircleAvatar(
                            backgroundColor:
                            Color(
                              0xFFFFF7ED,
                            ),
                            child: Icon(
                              Icons
                                  .inventory_2,
                              color:
                              AppColors
                                  .salida,
                            ),
                          ),

                          title: Text(
                            producto.nombre,
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),

                          subtitle: Text(
                            'Stock disponible: ${producto.stock}',
                          ),

                          onTap: () {
                            setState(() {
                              productoSeleccionado =
                                  producto;
                            });

                            Navigator.pop(
                              context,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================
  // CONFIRMAR SALIDA
  // =========================================================

  void confirmarSalida() {
    // =======================================================
    // VALIDAR PRODUCTO
    // =======================================================

    if (productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes seleccionar un producto.',
          ),
          backgroundColor:
          AppColors.error,
        ),
      );

      return;
    }

    // =======================================================
    // VALIDAR CANTIDAD
    // =======================================================

    final cantidad = int.tryParse(
      cantidadController.text.trim(),
    );

    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa una cantidad válida.',
          ),
          backgroundColor:
          AppColors.error,
        ),
      );

      return;
    }

    // =======================================================
    // VALIDAR STOCK
    // =======================================================

    if (cantidad >
        productoSeleccionado!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente. '
                'Disponible: '
                '${productoSeleccionado!.stock}',
          ),
          backgroundColor:
          AppColors.error,
        ),
      );

      return;
    }

    // =======================================================
    // REGISTRAR SALIDA
    // =======================================================

    final registrado =
    InventarioService.registrarSalida(
      productoSeleccionado!,
      cantidad,
    );

    if (!registrado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo registrar la salida.',
          ),
          backgroundColor:
          AppColors.error,
        ),
      );

      return;
    }

    // =======================================================
    // MENSAJE DE ÉXITO
    // =======================================================

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Salida realizada correctamente.\n'
              '${productoSeleccionado!.nombre} -$cantidad',
        ),
        backgroundColor:
        AppColors.salida,
        duration:
        const Duration(seconds: 2),
      ),
    );

    // =======================================================
    // REGRESAR AL HOME
    // =======================================================

    Future.delayed(
      const Duration(milliseconds: 500),
          () {
        if (!mounted) {
          return;
        }

        Navigator.pop(context);
      },
    );
  }

  // =========================================================
  // LIBERAR RECURSOS
  // =========================================================

  @override
  void dispose() {
    cantidadController.dispose();

    _speech.stop();

    super.dispose();
  }

  // =========================================================
  // INTERFAZ
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrar salida',
          style:
          AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        backgroundColor:
        AppColors.salida,
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            // =================================================
            // TÍTULO
            // =================================================

            const Text(
              'Nueva salida',
              style:
              AppTextStyles.title,
            ),

            const SizedBox(height: 8),

            const Text(
              'Indica la cantidad y el producto mediante voz o selecciónalo manualmente.',
              style:
              AppTextStyles.subtitle,
            ),

            const SizedBox(height: 25),

            // =================================================
            // INSTRUCCIÓN DE VOZ
            // =================================================

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(16),

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFFFF7ED,
                ),

                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),

              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    'Búsqueda por voz',
                    style:
                    AppTextStyles
                        .sectionTitle,
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Di primero la cantidad y luego el producto.',
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Ejemplo: "5 Paracetamol"',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color:
                      AppColors.salida,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // BOTÓN VOZ
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed:
                escucharSalida,

                icon: Icon(
                  escuchando
                      ? Icons.stop
                      : Icons.mic,
                ),

                label: Text(
                  escuchando
                      ? 'Escuchando...'
                      : 'Hablar cantidad + producto',
                  style:
                  AppTextStyles.button,
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  escuchando
                      ? Colors.red
                      : AppColors.salida,

                  foregroundColor:
                  AppColors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),

            // =================================================
            // TEXTO DETECTADO
            // =================================================

            if (textoVoz.isNotEmpty) ...[
              const SizedBox(height: 12),

              Text(
                'Detectado: "$textoVoz"',
                style:
                AppTextStyles.subtitle,
              ),
            ],

            const SizedBox(height: 30),

            // =================================================
            // CANTIDAD
            // =================================================

            const Text(
              'Cantidad',
              style:
              AppTextStyles.label,
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
              cantidadController,

              keyboardType:
              TextInputType.number,

              decoration:
              InputDecoration(
                hintText:
                'Ingrese la cantidad',

                prefixIcon:
                const Icon(
                  Icons.numbers,
                ),

                filled: true,

                fillColor:
                AppColors.white,

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // PRODUCTO
            // =================================================

            const Text(
              'Producto',
              style:
              AppTextStyles.label,
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),

              decoration:
              BoxDecoration(
                color:
                AppColors.white,

                borderRadius:
                BorderRadius.circular(
                  15,
                ),

                border: Border.all(
                  color:
                  Colors.grey.shade300,
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2,
                    color:
                    AppColors.salida,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Text(
                          productoSeleccionado
                              ?.nombre ??
                              'Seleccione un producto',

                          style: TextStyle(
                            color:
                            productoSeleccionado ==
                                null
                                ? Colors.grey
                                : Colors.black,

                            fontWeight:
                            productoSeleccionado ==
                                null
                                ? FontWeight
                                .normal
                                : FontWeight
                                .w600,
                          ),
                        ),

                        if (productoSeleccionado !=
                            null)
                          Text(
                            'Stock disponible: '
                                '${productoSeleccionado!.stock}',
                            style:
                            AppTextStyles
                                .small,
                          ),
                      ],
                    ),
                  ),

                  // =================================================
                  // LUPA
                  // =================================================

                  IconButton(
                    onPressed:
                    mostrarBusquedaProductos,

                    icon:
                    const Icon(
                      Icons.search,
                    ),

                    color:
                    AppColors.salida,

                    tooltip:
                    'Buscar producto',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // RESUMEN
            // =================================================

            if (productoSeleccionado !=
                null &&
                cantidadController
                    .text
                    .isNotEmpty)
              Container(
                width: double.infinity,

                padding:
                const EdgeInsets.all(
                  16,
                ),

                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFFEF2F2,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),

                child: Text(
                  'Salida: '
                      '${cantidadController.text} × '
                      '${productoSeleccionado!.nombre}',

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF991B1B),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // =================================================
            // CONFIRMAR SALIDA
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                onPressed:
                confirmarSalida,

                icon:
                const Icon(
                  Icons.check_circle,
                ),

                label: const Text(
                  'CONFIRMAR SALIDA',
                  style:
                  AppTextStyles.button,
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.salida,

                  foregroundColor:
                  AppColors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
