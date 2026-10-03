import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart'
as stt;

import '../models/producto.dart';
import '../models/usuario.dart';
import '../viewmodels/salida_viewmodel.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class Salida extends StatefulWidget {
  final Usuario? usuario;

  const Salida({
    super.key,
    this.usuario,
  });

  @override
  State<Salida> createState() =>
      _SalidaState();
}

class _SalidaState extends State<Salida> {
  // =========================================================
  // VIEW MODEL
  // =========================================================

  final SalidaViewModel _viewModel =
  SalidaViewModel();

  // =========================================================
  // VOZ
  // =========================================================

  final stt.SpeechToText _speech =
  stt.SpeechToText();

  bool escuchando = false;
  bool vozDisponible = false;

  // =========================================================
  // CAMPOS
  // =========================================================

  final TextEditingController
  cantidadController =
  TextEditingController();

  String textoVoz = '';

  // =========================================================
  // INICIALIZACIÓN
  // =========================================================

  @override
  void initState() {
    super.initState();

    // Escuchar cambios del ViewModel
    _viewModel.addListener(
      _actualizarVista,
    );

    inicializarVoz();
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
  // INICIALIZAR RECONOCIMIENTO DE VOZ
  // =========================================================

  Future<void> inicializarVoz() async {
    vozDisponible =
    await _speech.initialize(
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
  // "10 Paracetamol"
  //
  // =========================================================

  Future<void> escucharSalida() async {
    if (!vozDisponible) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
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
      textoVoz = '';
    });

    await _speech.listen(
      localeId: 'es-PE',
      onResult: (resultado) {
        final texto =
            resultado.recognizedWords;

        if (!mounted) {
          return;
        }

        setState(() {
          textoVoz = texto;
        });

        procesarTextoVoz(texto);
      },
    );
  }

  // =========================================================
  // PROCESAR:
  //
  // cantidad + producto
  //
  // Ejemplo:
  //
  // "10 Paracetamol"
  //
  // =========================================================

  void procesarTextoVoz(
      String texto,
      ) {
    if (texto.trim().isEmpty) {
      return;
    }

    final palabras =
    texto.trim().split(
      RegExp(r'\s+'),
    );

    if (palabras.isEmpty) {
      return;
    }

    // ---------------------------------------------------------
    // PRIMERA PALABRA = CANTIDAD
    // ---------------------------------------------------------

    final cantidadTexto =
        palabras.first;

    final cantidad =
    int.tryParse(cantidadTexto);

    if (cantidad == null) {
      return;
    }

    cantidadController.text =
        cantidad.toString();

    // ---------------------------------------------------------
    // RESTO = PRODUCTO
    // ---------------------------------------------------------

    if (palabras.length < 2) {
      return;
    }

    final nombreProducto =
    palabras.sublist(1).join(' ');

    buscarProductoPorTexto(
      nombreProducto,
    );
  }

  // =========================================================
  // BUSCAR PRODUCTO
  // =========================================================

  Future<void> buscarProductoPorTexto(
      String texto,
      ) async {
    await _viewModel
        .buscarYSeleccionarProducto(
      texto,
    );
  }

  // =========================================================
  // BUSCAR MANUALMENTE
  // =========================================================

  void mostrarBusquedaProductos() {
    String busqueda = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setModalState) {
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
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  const Text(
                    'Buscar producto',
                    style: AppTextStyles
                        .sectionTitle,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  TextField(
                    autofocus: true,
                    onChanged: (valor) {
                      setModalState(() {
                        busqueda = valor;
                      });
                    },
                    decoration:
                    InputDecoration(
                      hintText:
                      'Buscar producto...',
                      prefixIcon:
                      const Icon(
                        Icons.search,
                      ),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // =================================================
                  // LISTA DESDE EL VIEW MODEL
                  // =================================================

                  FutureBuilder<
                      List<Producto>>(
                    future:
                    _viewModel
                        .buscarProductos(
                      busqueda,
                    ),
                    builder:
                        (context, snapshot) {
                      if (snapshot
                          .connectionState ==
                          ConnectionState
                              .waiting) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child:
                            CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot
                          .hasError) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              'Error al cargar los productos.',
                            ),
                          ),
                        );
                      }

                      final productos =
                          snapshot.data ?? [];

                      if (productos.isEmpty) {
                        return const SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              'No se encontró el producto.',
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 300,
                        child:
                        ListView.builder(
                          itemCount:
                          productos.length,
                          itemBuilder:
                              (
                              context,
                              index,
                              ) {
                            final producto =
                            productos[
                            index];

                            return ListTile(
                              leading:
                              const CircleAvatar(
                                backgroundColor:
                                Color(
                                  0xFFFFF1F2,
                                ),
                                child: Icon(
                                  Icons
                                      .inventory_2,
                                  color:
                                  Colors.red,
                                ),
                              ),
                              title: Text(
                                producto
                                    .nombre,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                              subtitle: Text(
                                'Stock: ${producto.stock}',
                              ),
                              onTap: () {
                                // =================================
                                // SELECCIONAR EN VIEW MODEL
                                // =================================

                                _viewModel
                                    .seleccionarProducto(
                                  producto,
                                );

                                Navigator.pop(
                                  context,
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
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

  Future<void> confirmarSalida() async {
    final productoSeleccionado =
        _viewModel
            .productoSeleccionado;

    // =======================================================
    // VALIDAR PRODUCTO
    // =======================================================

    if (productoSeleccionado == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Debes seleccionar un producto.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // =======================================================
    // VALIDAR CANTIDAD
    // =======================================================

    final cantidad =
    int.tryParse(
      cantidadController.text.trim(),
    );

    if (cantidad == null ||
        cantidad <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa una cantidad válida.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // =======================================================
    // VALIDAR STOCK
    // =======================================================

    if (cantidad >
        productoSeleccionado.stock) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Stock insuficiente.\n'
                'Stock actual: ${productoSeleccionado.stock}',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // =======================================================
    // CODIGO DEL USUARIO LOGUEADO
    // =======================================================

    final codUsuario =
        widget.usuario?.cod_usuario ?? '';

    if (codUsuario.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No se encontró el usuario que inició sesión.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // =======================================================
    // REGISTRAR SALIDA
    // =======================================================

    final registrado =
    await _viewModel
        .registrarSalida(
      cantidad,
      codUsuario,
    );

    if (!mounted) {
      return;
    }

    // =======================================================
    // VALIDAR RESULTADO
    // =======================================================

    if (!registrado) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo registrar la salida.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // =======================================================
    // MENSAJE DE ÉXITO
    // =======================================================

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Salida realizada correctamente.\n'
              '${productoSeleccionado.nombre} -$cantidad',
        ),
        backgroundColor:
        AppColors.salida,
        duration:
        const Duration(seconds: 2),
      ),
    );

    // =======================================================
    // VOLVER AL HOME
    // =======================================================

    Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
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

    _viewModel.removeListener(
      _actualizarVista,
    );

    _viewModel.dispose();

    super.dispose();
  }

  // =========================================================
  // INTERFAZ
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    // =========================================================
    // DATOS CONTROLADOS POR VIEW MODEL
    // =========================================================

    final productoSeleccionado =
        _viewModel
            .productoSeleccionado;

    final registrando =
        _viewModel.registrando;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrar salida',
          style:
          AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            const Text(
              'Nueva salida',
              style: AppTextStyles.title,
            ),

            const SizedBox(height: 8),

            const Text(
              'Indica la cantidad y el producto mediante voz o selecciónalo manualmente.',
              style:
              AppTextStyles.subtitle,
            ),

            const SizedBox(height: 25),

            // =================================================
            // INDICACIÓN DE VOZ
            // =================================================

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFFFF1F2,
                ),
                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    'Búsqueda por voz',
                    style: AppTextStyles
                        .sectionTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Di primero la cantidad y luego el producto.',
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ejemplo: "10 Paracetamol"',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.red,
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
              child:
              ElevatedButton.icon(
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
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  escuchando
                      ? Colors.red
                      : AppColors
                      .salida,
                  foregroundColor:
                  AppColors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
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
              const SizedBox(
                height: 12,
              ),

              Text(
                'Detectado: "$textoVoz"',
                style:
                AppTextStyles
                    .subtitle,
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
                fillColor: Colors.white,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    15,
                  ),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
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
              const EdgeInsets
                  .symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius
                    .circular(
                  15,
                ),
                border: Border.all(
                  color:
                  Colors.grey
                      .shade300,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2,
                    color: Colors.red,
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
                                ? Colors
                                .grey
                                : Colors
                                .black,
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
                            'Stock actual: '
                                '${productoSeleccionado.stock}',
                            style:
                            AppTextStyles
                                .small,
                          ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed:
                    mostrarBusquedaProductos,
                    icon: const Icon(
                      Icons.search,
                    ),
                    color: Colors.orange,
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
                    .text.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  16,
                ),
                decoration:
                BoxDecoration(
                  color: const Color(
                    0xFFFFF1F2,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    15,
                  ),
                ),
                child: Text(
                  'Salida: '
                      '${cantidadController.text} × '
                      '${productoSeleccionado.nombre}',
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(
                      0xFF991B1B,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // =================================================
            // CONFIRMAR
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 58,
              child:
              ElevatedButton.icon(
                onPressed:
                registrando
                    ? null
                    : confirmarSalida,
                icon: registrando
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons
                      .check_circle,
                ),
                label: Text(
                  registrando
                      ? 'REGISTRANDO...'
                      : 'CONFIRMAR SALIDA',
                  style:
                  AppTextStyles
                      .button,
                ),
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  AppColors.salida,
                  foregroundColor:
                  AppColors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
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