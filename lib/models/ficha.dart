/// Refleja Modelo/Ficha.java y el JSON de Servlet/ConsultarFichas.java.
class Ficha {
  final int id;
  final int codigo;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int cantidadAprendices;
  final int programaId;
  final int jornadaId;
  final int modalidadId;
  final int nivelFormacionId;
  final int sedeId;
  final int estadoId;
  final int etapaId;

  Ficha({
    this.id = 0,
    required this.codigo,
    this.fechaInicio,
    this.fechaFin,
    this.cantidadAprendices = 0,
    required this.programaId,
    required this.jornadaId,
    required this.modalidadId,
    required this.nivelFormacionId,
    required this.sedeId,
    required this.estadoId,
    required this.etapaId,
  });

  factory Ficha.fromJson(Map<String, dynamic> j) => Ficha(
        id: j['id'] as int,
        codigo: j['codigo'] as int,
        fechaInicio: j['fechaInicio'] != null ? DateTime.tryParse(j['fechaInicio']) : null,
        fechaFin: j['fechaFin'] != null ? DateTime.tryParse(j['fechaFin']) : null,
        cantidadAprendices: (j['cantidadAprendices'] ?? 0) as int,
        programaId: j['programaId'] as int,
        jornadaId: j['jornadaId'] as int,
        modalidadId: j['modalidadId'] as int,
        nivelFormacionId: j['nivelFormacionId'] as int,
        sedeId: j['sedeId'] as int,
        estadoId: j['estadoId'] as int,
        etapaId: j['etapaId'] as int,
      );

  /// Campos tal como los espera RegistrarFicha/ActualizarFicha (form-urlencoded).
  Map<String, String> toForm() => {
        if (id != 0) 'id': id.toString(),
        'codigo_ficha': codigo.toString(),
        'Programas_idProgramas': programaId.toString(),
        'Jornada_id_jornada': jornadaId.toString(),
        'Modalidad_id_modalidad': modalidadId.toString(),
        'Nivel_formacion_id_nivel_formacion': nivelFormacionId.toString(),
        'Sede_id_sede': sedeId.toString(),
        'Estado_id_estado': estadoId.toString(),
        'Etapa_id_etapa': etapaId.toString(),
        'cantidad_aprendices': cantidadAprendices.toString(),
        if (fechaInicio != null) 'fecha_inicio': fechaInicio!.toIso8601String().split('T').first,
        if (fechaFin != null) 'fecha_fin': fechaFin!.toIso8601String().split('T').first,
      };
}
