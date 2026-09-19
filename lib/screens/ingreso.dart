import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/producto.dart';
import '../services/inventario_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class Ingreso extends StatefulWidget {
  const Ingreso({super.key});

  @override
  State<Ingreso> createState() => _IngresoState();
}

class _IngresoState extends State<Ingreso> {
  // =========================================================
  // VOZ
  // =========================================================

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool escuchando = false;
  bool vozDisponible = false;

  // =========================================================
  // CAMPOS
  // =========================================================

  final TextEditingController cantidadController =
  TextEditingController();

  // Texto que se muestra como resultado de la voz
  String textoVoz = '';

  // Producto seleccionado
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
  // INICIALIZAR RECONOCIMIENTO DE VOZ
  // =========================================================

  Future<void> inicializarVoz() async {
    vozDisponible = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
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
  // "10 mouse Logitech"
  //
  // =========================================================

  Future<void> escucharIngreso() async {
    if (!vozDisponible) {
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
  // PROCESAR:
  //
  // cantidad + producto
  //
  // Ejemplo:
  //
  // "10 mouse Logitech"
  //
  // =========================================================

  void procesarTextoVoz(String texto) {
    if (texto.trim().isEmpty) {
      return;
    }

    final palabras = texto.trim().split(RegExp(r'\s+'));

    if (palabras.isEmpty) {
      return;
    }

    // ---------------------------------------------------------
    // PRIMERA PALABRA = CANTIDAD
    // ---------------------------------------------------------

    final cantidadTexto = palabras.first;

    final cantidad = int.tryParse(cantidadTexto);

    if (cantidad == null) {
      return;
    }

    cantidadController.text = cantidad.toString();

    // ---------------------------------------------------------
    // RESTO = PRODUCTO
    // ---------------------------------------------------------

    if (palabras.length < 2) {
      return;
    }

    final nombreProducto = palabras.sublist(1).join(' ');

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

    // Primero intentamos coincidencia exacta
    final exacto =
    InventarioService.buscarProducto(texto);

    setState(() {
      productoSeleccionado = exacto ?? productos.first;
    });
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final productos =
            InventarioService.filtrarProductos(busqueda);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Buscar producto',
                    style: AppTextStyles.sectionTitle,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    autofocus: true,
                    onChanged: (valor) {
                      setModalState(() {
                        busqueda = valor;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon:
                      const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 300,
                    child: productos.isEmpty
                        ? const Center(
                      child: Text(
                        'No se encontró el producto.',
                      ),
                    )
                        : ListView.builder(
                      itemCount: productos.length,
                      itemBuilder:
                          (context, index) {
                        final producto =
                        productos[index];

                        return ListTile(
                          leading:
                          const CircleAvatar(
                            backgroundColor:
                            Color(0xFFEFF6FF),
                            child: Icon(
                              Icons.inventory_2,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            producto.nombre,
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Stock: ${producto.stock}',
                          ),
                          onTap: () {
                            setState(() {
                              productoSeleccionado =
                                  producto;
                            });

                            Navigator.pop(context);
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
  // CONFIRMAR INGRESO
  // =========================================================

  void confirmarIngreso() {
    if (productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes seleccionar un producto.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final cantidad =
    int.tryParse(cantidadController.text.trim());

    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa una cantidad válida.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final registrado =
    InventarioService.registrarIngreso(
      productoSeleccionado!,
      cantidad,
    );

    if (!registrado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo registrar el ingreso.',
          ),
          backgroundColor: Colors.red,
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
          'Ingreso realizado correctamente.\n'
              '${productoSeleccionado!.nombre} +$cantidad',
        ),
        backgroundColor: AppColors.ingreso,
        duration: const Duration(seconds: 2),
      ),
    );

    // =======================================================
    // VOLVER AL HOME
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
          'Registrar ingreso',
          style: AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            const Text(
              'Nuevo ingreso',
              style: AppTextStyles.title,
            ),

            const SizedBox(height: 8),

            const Text(
              'Indica la cantidad y el producto mediante voz o selecciónalo manualmente.',
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 25),

            // =================================================
            // INDICACIÓN DE VOZ
            // =================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius:
                BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Búsqueda por voz',
                    style:
                    AppTextStyles.sectionTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Di primero la cantidad y luego el producto.',
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ejemplo: "10 Paracetamol"',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
                onPressed: escucharIngreso,
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
                  backgroundColor: escuchando
                      ? Colors.red
                      : AppColors.primary,
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
              controller: cantidadController,
              keyboardType:
              TextInputType.number,
              decoration: InputDecoration(
                hintText:
                'Ingrese la cantidad',
                prefixIcon:
                const Icon(Icons.numbers),
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(15),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2,
                    color: Colors.blue,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
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
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed:
                    mostrarBusquedaProductos,
                    icon:
                    const Icon(Icons.search),
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

            if (productoSeleccionado != null &&
                cantidadController.text.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFF0FDF4),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Text(
                  'Ingreso: ${cantidadController.text} × '
                      '${productoSeleccionado!.nombre}',
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF166534),
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
              child: ElevatedButton.icon(
                onPressed:
                confirmarIngreso,
                icon: const Icon(
                  Icons.check_circle,
                ),
                label: const Text(
                  'CONFIRMAR INGRESO',
                  style:
                  AppTextStyles.button,
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.ingreso,
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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
