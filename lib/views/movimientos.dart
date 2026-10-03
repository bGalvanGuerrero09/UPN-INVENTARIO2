import 'package:flutter/material.dart';

import '../models/inventario.dart';
import '../models/producto.dart';
import '../models/usuario.dart';
import '../models/combos.dart';

import '../viewmodels/movimientos_viewmodel.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class Movimientos extends StatefulWidget {
  final Usuario? usuario;

  const Movimientos({
    super.key,
    this.usuario,
  });

  @override
  State<Movimientos> createState() =>
      _MovimientosState();
}

class _MovimientosState
    extends State<Movimientos> {
  // =============================================================
  // VIEW MODEL
  // =============================================================

  final MovimientosViewModel _viewModel =
  MovimientosViewModel();

  // =============================================================
  // INICIO
  // =============================================================

  @override
  void initState() {
    super.initState();

    _viewModel.addListener(
      _actualizarVista,
    );

    cargarDatos();
  }

  // =============================================================
  // ACTUALIZAR VISTA
  // =============================================================

  void _actualizarVista() {
    if (mounted) {
      setState(() {});
    }
  }

  // =============================================================
  // CARGAR DATOS
  // =============================================================

  Future<void> cargarDatos() async {
    try {
      await _viewModel.cargarDatos(
        codUsuario:
        widget.usuario?.cod_usuario,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar los movimientos: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =============================================================
  // LIMPIAR FILTROS
  // =============================================================

  void limpiarFiltros() {
    _viewModel.limpiarFiltros(
      codUsuario:
      widget.usuario?.cod_usuario,
    );
  }

  // =============================================================
  // SELECCIONAR PRODUCTO
  // =============================================================

  Future<void> seleccionarProducto() async {
    final producto =
    await showSearch<Producto?>(
      context: context,
      delegate: _ProductoSearchDelegate(
        _viewModel.productos,
        _viewModel.productoSeleccionado,
      ),
    );

    if (producto == null) {
      return;
    }

    _viewModel.seleccionarProducto(
      producto,
    );
  }

  // =============================================================
  // SELECCIONAR USUARIO
  // =============================================================

  Future<void> seleccionarUsuario() async {
    final usuario =
    await showSearch<Combos?>(
      context: context,
      delegate: _UsuarioSearchDelegate(
        _viewModel.usuarios,
        _viewModel.usuarioSeleccionado,
      ),
    );

    if (usuario == null) {
      return;
    }

    _viewModel.seleccionarUsuario(
      usuario,
    );
  }

  // =============================================================
  // MOSTRAR DETALLE
  // =============================================================

  void mostrarDetalle(
      Inventario movimiento,
      ) {
    final esIngreso =
        movimiento.codTipoMovimiento ==
            'ING';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                esIngreso
                    ? Icons.add_circle
                    : Icons.remove_circle,
                color: esIngreso
                    ? AppColors.ingreso
                    : AppColors.salida,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Detalle del movimiento',
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _DetalleItem(
                  titulo: 'Producto',
                  valor:
                  movimiento.dscProducto,
                ),

                _DetalleItem(
                  titulo: 'Código',
                  valor:
                  movimiento.codProducto,
                ),

                _DetalleItem(
                  titulo: 'Tipo',
                  valor: movimiento.dscTipo,
                ),

                _DetalleItem(
                  titulo: 'Cantidad',
                  valor: movimiento
                      .ctdMovimiento
                      .toString(),
                ),

                _DetalleItem(
                  titulo: 'Unidad',
                  valor:
                  movimiento.dscUnidad,
                ),

                _DetalleItem(
                  titulo: 'Área',
                  valor:
                  movimiento.dscArea,
                ),

                _DetalleItem(
                  titulo: 'Ubicación',
                  valor:
                  movimiento.dscUbicacion,
                ),

                _DetalleItem(
                  titulo: 'Usuario',
                  valor:
                  movimiento.dscUsuario,
                ),

                _DetalleItem(
                  titulo: 'Código usuario',
                  valor:
                  movimiento.codUsuario,
                ),

                _DetalleItem(
                  titulo: 'Fecha',
                  valor:
                  _viewModel
                      .formatearFecha(
                    movimiento
                        .fchMovimiento,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
              const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // =============================================================
  // CARTILLA STOCK ACTUAL
  // =============================================================

  Widget _buildStockActual() {
    final producto =
    _viewModel
        .obtenerProductoSeleccionado();

    if (producto == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        10,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
              Colors.blue.shade100,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              Icons.inventory_2,
              color:
              Colors.blue.shade700,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock actual',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    Colors.blue.shade700,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  producto.nombre,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${producto.stock}',
            style: TextStyle(
              fontSize: 24,
              fontWeight:
              FontWeight.bold,
              color:
              Colors.blue.shade700,
            ),
          ),

          const SizedBox(width: 5),

          Text(
            producto.dscUnidad,
            style: TextStyle(
              fontSize: 12,
              color:
              Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final movimientos =
        _viewModel.movimientos;

    final cargando =
        _viewModel.cargando;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movimientos',
          style:
          AppTextStyles.appBarTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
            const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: cargarDatos,
          ),
        ],
      ),

      body: cargando
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : Column(
        children: [
          // =================================================
          // FILTROS
          // =================================================

          Padding(
            padding:
            const EdgeInsets
                .fromLTRB(
              16,
              12,
              16,
              8,
            ),
            child: Column(
              children: [
                // ===========================================
                // PRODUCTO
                // ===========================================

                InkWell(
                  onTap:
                  seleccionarProducto,
                  borderRadius:
                  BorderRadius
                      .circular(10),
                  child:
                  InputDecorator(
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Producto',
                      border:
                      OutlineInputBorder(),
                      prefixIcon:
                      Icon(
                        Icons
                            .inventory_2,
                      ),
                      suffixIcon:
                      Icon(
                        Icons.search,
                      ),
                      isDense: true,
                    ),
                    child: Text(
                      _viewModel
                          .textoProducto,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // ===========================================
                // USUARIO
                // ===========================================

                InkWell(
                  onTap:
                  seleccionarUsuario,
                  borderRadius:
                  BorderRadius
                      .circular(10),
                  child:
                  InputDecorator(
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Usuario',
                      border:
                      OutlineInputBorder(),
                      prefixIcon:
                      Icon(
                        Icons.person,
                      ),
                      suffixIcon:
                      Icon(
                        Icons.search,
                      ),
                      isDense: true,
                    ),
                    child: Text(
                      _viewModel
                          .textoUsuario,
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // ===========================================
                // LIMPIAR
                // ===========================================

                SizedBox(
                  width:
                  double.infinity,
                  height: 38,
                  child:
                  OutlinedButton
                      .icon(
                    onPressed:
                    limpiarFiltros,
                    icon:
                    const Icon(
                      Icons
                          .filter_alt_off,
                      size: 18,
                    ),
                    label:
                    const Text(
                      'Limpiar filtros',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // STOCK ACTUAL
          // =================================================

          _buildStockActual(),

          // =================================================
          // CONTADOR
          // =================================================

          Padding(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Row(
              children: [
                Text(
                  '${movimientos.length} movimiento(s)',
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight
                        .bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // LISTA
          // =================================================

          Expanded(
            child:
            movimientos.isEmpty
                ? _buildSinMovimientos()
                : RefreshIndicator(
              onRefresh:
              cargarDatos,
              child:
              ListView
                  .builder(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  16,
                  0,
                  16,
                  10,
                ),
                itemCount:
                movimientos
                    .length,
                itemBuilder:
                    (context,
                    index) {
                  final movimiento =
                  movimientos[
                  index];

                  return _buildMovimientoCard(
                    movimiento,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CARD MOVIMIENTO
  // =============================================================

  Widget _buildMovimientoCard(
      Inventario movimiento,
      ) {
    final esIngreso =
        movimiento.codTipoMovimiento ==
            'ING';

    final color = esIngreso
        ? AppColors.ingreso
        : AppColors.salida;

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 6,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(10),
        onTap: () {
          mostrarDetalle(movimiento);
        },
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          child: Row(
            children: [
              // =================================================
              // ICONO
              // =================================================

              Container(
                width: 38,
                height: 38,
                decoration:
                BoxDecoration(
                  color:
                  color.withOpacity(
                    0.12,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(9),
                ),
                child: Icon(
                  esIngreso
                      ? Icons.add
                      : Icons.remove,
                  color: color,
                  size: 21,
                ),
              ),

              const SizedBox(width: 9),

              // =================================================
              // INFORMACIÓN PRINCIPAL
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            movimiento
                                .dscProducto,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              fontSize:
                              14,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Text(
                          '${esIngreso ? '+' : '-'}${movimiento.ctdMovimiento}',
                          style:
                          TextStyle(
                            color: color,
                            fontSize: 15,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      '${movimiento.codProducto} • ${movimiento.dscUnidad}',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style: TextStyle(
                        color: Colors
                            .grey.shade600,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons
                              .person_outline,
                          size: 13,
                          color: Colors
                              .grey.shade600,
                        ),

                        const SizedBox(
                          width: 3,
                        ),

                        Expanded(
                          child: Text(
                            movimiento
                                .dscUsuario
                                .isEmpty
                                ? movimiento
                                .codUsuario
                                : movimiento
                                .dscUsuario,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              color: Colors
                                  .grey
                                  .shade700,
                              fontSize:
                              11,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Icon(
                          Icons
                              .calendar_today,
                          size: 11,
                          color: Colors
                              .grey.shade600,
                        ),

                        const SizedBox(
                          width: 3,
                        ),

                        Text(
                          _viewModel
                              .formatearFechaCorta(
                            movimiento
                                .fchMovimiento,
                          ),
                          style:
                          TextStyle(
                            color: Colors
                                .grey
                                .shade700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // =================================================
              // TIPO
              // =================================================

              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration:
                BoxDecoration(
                  color:
                  color.withOpacity(
                    0.12,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(15),
                ),
                child: Text(
                  esIngreso
                      ? 'ING'
                      : 'SAL',
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SIN MOVIMIENTOS
  // =============================================================

  Widget _buildSinMovimientos() {
    return RefreshIndicator(
      onRefresh: cargarDatos,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 60),

          Icon(
            Icons.history,
            size: 60,
            color:
            Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              'No se encontraron movimientos',
              style: TextStyle(
                color:
                Colors.grey.shade600,
                fontSize: 15,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Center(
            child: Text(
              'Prueba cambiando los filtros.',
              style: TextStyle(
                color:
                Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // LIBERAR RECURSOS
  // =============================================================

  @override
  void dispose() {
    _viewModel.removeListener(
      _actualizarVista,
    );

    _viewModel.dispose();

    super.dispose();
  }
}

// =============================================================
// DETALLE
// =============================================================

class _DetalleItem
    extends StatelessWidget {
  final String titulo;
  final String valor;

  const _DetalleItem({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 12,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            valor.isEmpty
                ? '-'
                : valor,
            style:
            const TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// BUSCADOR DE PRODUCTOS
// =============================================================

class _ProductoSearchDelegate
    extends SearchDelegate<Producto?> {
  final List<Producto> productos;

  final String?
  productoSeleccionado;

  _ProductoSearchDelegate(
      this.productos,
      this.productoSeleccionado,
      );

  @override
  List<Widget>? buildActions(
      BuildContext context,
      ) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon:
          const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(
      BuildContext context,
      ) {
    return IconButton(
      icon:
      const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(
      BuildContext context,
      ) {
    return _buildLista();
  }

  @override
  Widget buildSuggestions(
      BuildContext context,
      ) {
    return _buildLista();
  }

  Widget _buildLista() {
    final texto =
    query.trim().toLowerCase();

    final lista =
    productos.where((producto) {
      if (texto.isEmpty) {
        return true;
      }

      return producto.nombre
          .toLowerCase()
          .contains(texto) ||
          producto.codProducto
              .toLowerCase()
              .contains(texto) ||
          producto.dscUnidad
              .toLowerCase()
              .contains(texto) ||
          producto.dscArea
              .toLowerCase()
              .contains(texto);
    }).toList();

    return ListView.builder(
      itemCount: lista.length + 1,
      itemBuilder:
          (context, index) {
        // =======================================================
        // TODOS LOS PRODUCTOS
        // =======================================================

        if (index == 0) {
          return ListTile(
            leading:
            const CircleAvatar(
              child: Icon(
                Icons.all_inclusive,
              ),
            ),
            title: const Text(
              'Todos los productos',
            ),
            subtitle: const Text(
              'Mostrar todos',
            ),
            onTap: () {
              close(
                context,
                Producto(
                  codProducto: '',
                  nombre: '',
                  codUnidad: '',
                  dscUnidad: '',
                  codArea: '',
                  dscArea: '',
                  ubicacion: '',
                  stock: 0,
                ),
              );
            },
          );
        }

        final producto =
        lista[index - 1];

        final seleccionado =
            producto.codProducto ==
                productoSeleccionado;

        return ListTile(
          leading:
          const CircleAvatar(
            child: Icon(
              Icons.inventory_2,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  producto.nombre,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // STOCK EN LA BÚSQUEDA
              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.blue.shade50,
                  borderRadius:
                  BorderRadius
                      .circular(10),
                ),
                child: Text(
                  'Stock: ${producto.stock}',
                  style: TextStyle(
                    color: Colors
                        .blue.shade700,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            '${producto.codProducto} • ${producto.dscUnidad}',
          ),
          trailing: seleccionado
              ? const Icon(
            Icons.check,
            color: Colors.green,
          )
              : null,
          onTap: () {
            close(
              context,
              producto,
            );
          },
        );
      },
    );
  }
}

// =============================================================
// BUSCADOR DE USUARIOS
// =============================================================

class _UsuarioSearchDelegate
    extends SearchDelegate<Combos?> {
  final List<Combos> usuarios;

  final String?
  usuarioSeleccionado;

  _UsuarioSearchDelegate(
      this.usuarios,
      this.usuarioSeleccionado,
      );

  @override
  List<Widget>? buildActions(
      BuildContext context,
      ) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon:
          const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(
      BuildContext context,
      ) {
    return IconButton(
      icon:
      const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(
      BuildContext context,
      ) {
    return _buildLista();
  }

  @override
  Widget buildSuggestions(
      BuildContext context,
      ) {
    return _buildLista();
  }

  Widget _buildLista() {
    final texto =
    query.trim().toLowerCase();

    final lista =
    usuarios.where((usuario) {
      if (texto.isEmpty) {
        return true;
      }

      return usuario.codvar
          .toLowerCase()
          .contains(texto) ||
          usuario.desvar1
              .toLowerCase()
              .contains(texto);
    }).toList();

    return ListView.builder(
      itemCount: lista.length + 1,
      itemBuilder:
          (context, index) {
        // =======================================================
        // TODOS LOS USUARIOS
        // =======================================================

        if (index == 0) {
          return ListTile(
            leading:
            const CircleAvatar(
              child: Icon(
                Icons.people,
              ),
            ),
            title: const Text(
              'Todos los usuarios',
            ),
            subtitle: const Text(
              'Mostrar todos',
            ),
            onTap: () {
              close(
                context,
                Combos(
                  codvar: '',
                  desvar1: '',
                ),
              );
            },
          );
        }

        final usuario =
        lista[index - 1];

        final seleccionado =
            usuario.codvar ==
                usuarioSeleccionado;

        return ListTile(
          leading:
          const CircleAvatar(
            child: Icon(
              Icons.person,
            ),
          ),
          title: Text(
            usuario.desvar1,
          ),
          subtitle: Text(
            usuario.codvar,
          ),
          trailing: seleccionado
              ? const Icon(
            Icons.check,
            color: Colors.green,
          )
              : null,
          onTap: () {
            close(
              context,
              usuario,
            );
          },
        );
      },
    );
  }
}