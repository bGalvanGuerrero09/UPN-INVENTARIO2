class Usuario {
  final String cod_usuario;
  final String dsc_usuario;
  final String dsc_clave;

  Usuario({
    required this.cod_usuario,
    required this.dsc_usuario,
    required this.dsc_clave,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      cod_usuario: json['cod_usuario'] ?? '',
      dsc_usuario: json['dsc_usuario'] ?? '',
      dsc_clave: json['dsc_clave'] ?? '',
    );
  }
}