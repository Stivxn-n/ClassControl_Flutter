/// Un item de catalogo generico: {id, etiqueta}. Sirve para programas,
/// jornadas, modalidades, niveles, sedes, estados y etapas, que todos
/// vienen del backend como {"id": N, "descripcion|nombre": "..."}.
class CatalogoItem {
  final int id;
  final String etiqueta;
  CatalogoItem({required this.id, required this.etiqueta});

  factory CatalogoItem.fromJson(Map<String, dynamic> json) {
    final etiqueta = json['descripcion'] ?? json['nombre'] ?? json['codigo']?.toString() ?? '';
    return CatalogoItem(id: json['id'] as int, etiqueta: etiqueta.toString());
  }
}
