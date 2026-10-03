class Producto {
  String codProducto;
  String nombre;
  String codUnidad;
  String dscUnidad;
  String codArea;
  String dscArea;
  String ubicacion;
  int stock;

  Producto({
    required this.codProducto,
    required this.nombre,
    required this.codUnidad,
    required this.dscUnidad,
    required this.codArea,
    required this.dscArea,
    required this.ubicacion,
    required this.stock,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      codProducto: json['cod_producto'] ?? '',
      nombre: json['dsc_producto'] ?? '',
      codUnidad: json['cod_unidad'] ?? '',
      dscUnidad: json['dsc_unidad'] ?? '',
      codArea: json['cod_area'] ?? '',
      dscArea: json['dsc_area'] ?? '',
      ubicacion: json['dsc_ubicacion'] ?? '',
      stock: json['ctd_stock'] ?? 0,
    );
  }
}
