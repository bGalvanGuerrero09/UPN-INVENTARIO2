class Combos {
  String codvar;
  String desvar1;

  Combos({
    required this.codvar,
    required this.desvar1,
  });

  factory Combos.fromJson(Map<String, dynamic> json) {
    return Combos(
      codvar: json['codvar'] ?? '',
      desvar1: json['desvar1'] ?? '',
    );
  }
}