/// Refleja Modelo/Programas.java. Ojo: en el backend real un programa
/// solo tiene codigo y nombre (no tiene "nivel" ni "version" ni "estado"
/// propios — el nivel de formacion vive en la Ficha, no en el Programa).
class Programa {
  final int id;
  final int codigo;
  final String nombre;

  Programa({this.id = 0, required this.codigo, required this.nombre});

  factory Programa.fromJson(Map<String, dynamic> j) => Programa(
        id: j['id'] as int,
        codigo: j['codigo'] as int,
        nombre: j['nombre'] ?? '',
      );

  Map<String, String> toForm() => {
        if (id != 0) 'id': id.toString(),
        'codigo_programa': codigo.toString(),
        'nombre_programa': nombre,
      };
}
