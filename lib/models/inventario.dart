class Inventario {
  String codProducto;
  String dscProducto;
  String codUnidad;
  String dscUnidad;
  String codArea;
  String dscArea;
  String dscUbicacion;
  String codTipoMovimiento;
  String dscTipo;
  DateTime fchMovimiento;
  int ctdMovimiento;
  String codUsuario;
  String dscUsuario;

  Inventario({
    required this.codProducto,
    required this.dscProducto,
    required this.codUnidad,
    required this.dscUnidad,
    required this.codArea,
    required this.dscArea,
    required this.dscUbicacion,
    required this.codTipoMovimiento,
    required this.dscTipo,
    required this.fchMovimiento,
    required this.ctdMovimiento,
    required this.codUsuario,
    required this.dscUsuario,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) {
    return Inventario(
      codProducto: json['cod_producto'] ?? '',
      dscProducto: json['dsc_producto'] ?? '',
      codUnidad: json['cod_unidad'] ?? '',
      dscUnidad: json['dsc_unidad'] ?? '',
      codArea: json['cod_area'] ?? '',
      dscArea: json['dsc_area'] ?? '',
      dscUbicacion: json['dsc_ubicacion'] ?? '',
      codTipoMovimiento: json['cod_tipo_movimiento'] ?? '',
      dscTipo: json['dsc_tipo'] ?? '',
      fchMovimiento: json['fch_movimiento'] == null
          ? DateTime.now()
          : DateTime.parse(json['fch_movimiento'].toString()),
      ctdMovimiento: json['ctd_movimiento'] == null
          ? 0
          : int.tryParse(
        json['ctd_movimiento'].toString(),
      ) ??
          0,
      codUsuario: json['cod_usuario'] ?? '',
      dscUsuario: json['dsc_usuario'] ?? '',
    );
  }
}