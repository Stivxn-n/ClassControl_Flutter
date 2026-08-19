import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_client.dart';
import '../services/remote_data_service.dart';
import '../widgets/page_header.dart';
import '../widgets/sidebar.dart';

class ProgramacionScreen extends StatefulWidget {
  final String rol;
  const ProgramacionScreen({super.key, required this.rol});
  @override
  State<ProgramacionScreen> createState() => _ProgramacionScreenState();
}

class _ProgramacionScreenState extends State<ProgramacionScreen> {
  List<Map<String, dynamic>> _items = [];
  final Map<String, List<Map<String, dynamic>>> _catalogos = {};
  bool _loading = true;
  String? _error;
  bool get _puedeGestionar =>
      widget.rol == 'admin' || widget.rol == 'coordinador';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await Future.wait([
        RemoteDataService.instance.list('/ConsultarProgramaciones'),
        RemoteDataService.instance.list('/ConsultarFichas'),
        RemoteDataService.instance.list('/ConsultarUsuarios'),
        RemoteDataService.instance.list('/ConsultarAmbientes'),
        RemoteDataService.instance.list('/ConsultarTrimestres'),
        RemoteDataService.instance.list('/ConsultarEstados'),
        RemoteDataService.instance.list('/ConsultarActividades'),
      ]);
      if (!mounted) return;
      setState(() {
        _items = r[0];
        _catalogos['fichas'] = r[1];
        _catalogos['usuarios'] = r[2];
        _catalogos['ambientes'] = r[3];
        _catalogos['trimestres'] = r[4];
        _catalogos['estados'] = r[5];
        _catalogos['actividades'] = r[6];
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted)
        setState(() => _error = 'No se pudo cargar la programación.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Row(children: [
        Sidebar(rol: widget.rol, paginaActual: 'programacion'),
        Expanded(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
              child: PageHeader(
                title: 'Programación de Instructores',
                subtitle: _puedeGestionar
                    ? 'Administra horarios, ambientes e instructores.'
                    : 'Horario registrado en ClassControl.',
                action: _puedeGestionar
                    ? ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva programación'))
                    : null,
              )),
          Expanded(child: _contenido()),
        ])),
      ]));

  Widget _contenido() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_error!, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Reintentar'))
      ]));
    if (_items.isEmpty)
      return RefreshIndicator(
          onRefresh: _load,
          child: ListView(children: const [
            SizedBox(height: 180),
            Center(child: Text('No hay programaciones registradas.'))
          ]));
    return RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
          itemCount: _items.length,
          itemBuilder: (context, i) {
            final p = _items[i];
            return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.calendar_month)),
                  title: Text(
                      '${p['actividad'] ?? 'Actividad'} • ${p['ficha'] ?? 'Ficha'}',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${p['instructor'] ?? '-'} | Ambiente: ${p['ambiente'] ?? '-'}\n${p['diasSemana'] ?? '-'} | ${p['horaInicio'] ?? '-'} - ${p['horaFin'] ?? '-'} | ${p['fechaInicio'] ?? ''} → ${p['fechaFin'] ?? ''}'),
                  isThreeLine: true,
                  trailing: _puedeGestionar
                      ? Wrap(spacing: 2, children: [
                          IconButton(
                              tooltip: 'Editar',
                              onPressed: () => _mostrarFormulario(p),
                              icon: const Icon(Icons.edit_outlined)),
                          IconButton(
                              tooltip: 'Eliminar',
                              onPressed: () => _confirmarEliminar(p),
                              icon: const Icon(Icons.delete_outline,
                                  color: Color(0xFFB42318))),
                        ])
                      : null,
                ));
          },
        ));
  }

  Future<void> _mostrarFormulario([Map<String, dynamic>? item]) async {
    final editando = item != null;
    final observaciones =
        TextEditingController(text: item?['observaciones'] ?? '');
    final fechaInicio =
        TextEditingController(text: '${item?['fechaInicio'] ?? ''}');
    final fechaFin = TextEditingController(text: '${item?['fechaFin'] ?? ''}');
    final horaInicio =
        TextEditingController(text: '${item?['horaInicio'] ?? ''}');
    final horaFin = TextEditingController(text: '${item?['horaFin'] ?? ''}');
    String? ficha = '${item?['fichaId'] ?? ''}',
        instructor = '${item?['instructorId'] ?? ''}',
        ambiente = '${item?['ambienteId'] ?? ''}',
        trimestre = '${item?['trimestreId'] ?? ''}',
        estado = '${item?['estadoId'] ?? ''}',
        actividad = '${item?['actividadId'] ?? ''}';
    String dia = '${item?['diasSemana'] ?? 'LUN'}';
    String? aviso;
    bool guardando = false;
    await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (context, setModal) => AlertDialog(
                  title: Text(
                      editando ? 'Editar programación' : 'Nueva programación'),
                  content: SizedBox(
                      width: 620,
                      child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        _selector(
                            'Actividad',
                            _catalogos['actividades']!,
                            actividad,
                            (v) => setModal(() => actividad = v),
                            (x) => '${x['nombre'] ?? 'Actividad'}'),
                        _selector(
                            'Instructor',
                            _catalogos['usuarios']!,
                            instructor,
                            (v) => setModal(() => instructor = v),
                            (x) =>
                                '${x['nombres'] ?? ''} ${x['apellidos'] ?? ''}'
                                    .trim()),
                        _selector(
                            'Ficha',
                            _catalogos['fichas']!,
                            ficha,
                            (v) => setModal(() => ficha = v),
                            (x) => 'Ficha ${x['codigo'] ?? x['id']}'),
                        _selector(
                            'Ambiente',
                            _catalogos['ambientes']!,
                            ambiente,
                            (v) => setModal(() => ambiente = v),
                            (x) => '${x['descripcion'] ?? 'Ambiente'}'),
                        Row(children: [
                          Expanded(
                              child: _selector(
                                  'Trimestre',
                                  _catalogos['trimestres']!,
                                  trimestre,
                                  (v) => setModal(() => trimestre = v),
                                  (x) =>
                                      'Trimestre ${x['numTrimestre'] ?? x['id']}')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _selector(
                                  'Estado',
                                  _catalogos['estados']!,
                                  estado,
                                  (v) => setModal(() => estado = v),
                                  (x) => '${x['descripcion'] ?? 'Estado'}'))
                        ]),
                        DropdownButtonFormField<String>(
                            value: dia,
                            decoration: const InputDecoration(labelText: 'Día'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'LUN', child: Text('Lunes')),
                              DropdownMenuItem(
                                  value: 'MAR', child: Text('Martes')),
                              DropdownMenuItem(
                                  value: 'MIE', child: Text('Miércoles')),
                              DropdownMenuItem(
                                  value: 'JUE', child: Text('Jueves')),
                              DropdownMenuItem(
                                  value: 'VIE', child: Text('Viernes')),
                              DropdownMenuItem(
                                  value: 'SAB', child: Text('Sábado'))
                            ],
                            onChanged: (v) => setModal(() => dia = v ?? 'LUN')),
                        const SizedBox(height: 12),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Período de vigencia',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 6),
                        Row(children: [
                          Expanded(
                              child: _fechaCampo(
                                  context, 'Fecha inicio', fechaInicio)),
                          const SizedBox(width: 12),
                          Expanded(
                              child:
                                  _fechaCampo(context, 'Fecha fin', fechaFin)),
                        ]),
                        const SizedBox(height: 12),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Horario de cada día',
                                style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 6),
                        Row(children: [
                          Expanded(
                              child: _horaCampo(
                                  context, 'Hora inicio', horaInicio)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _horaCampo(context, 'Hora fin', horaFin)),
                        ]),
                        const SizedBox(height: 12),
                        TextField(
                            controller: observaciones,
                            maxLength: 45,
                            maxLines: 2,
                            decoration: const InputDecoration(
                                labelText: 'Observaciones (opcional)')),
                        if (aviso != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(aviso!,
                                  style: const TextStyle(
                                      color: Color(0xFFB42318)))),
                      ]))),
                  actions: [
                    TextButton(
                        onPressed: guardando
                            ? null
                            : () => Navigator.pop(dialogContext),
                        child: const Text('Cancelar')),
                    ElevatedButton(
                        onPressed: guardando
                            ? null
                            : () async {
                                if ([
                                      ficha,
                                      instructor,
                                      ambiente,
                                      trimestre,
                                      estado,
                                      actividad
                                    ].any((v) => v == null || v!.isEmpty) ||
                                    fechaInicio.text.isEmpty ||
                                    fechaFin.text.isEmpty ||
                                    horaInicio.text.isEmpty ||
                                    horaFin.text.isEmpty) {
                                  setModal(() => aviso =
                                      'Completa todos los campos obligatorios.');
                                  return;
                                }
                                setModal(() {
                                  guardando = true;
                                  aviso = 'Enviando programación al servidor...';
                                });
                                try {
                                  final data = <String, String>{
                                    'Observaciones': observaciones.text.trim(),
                                    'fecha_inicial_Prog':
                                        fechaInicio.text.trim(),
                                    'fecha_fin_Prog': fechaFin.text.trim(),
                                    'dias_Semana': dia,
                                    'hora_inicio': horaInicio.text.trim(),
                                    'hora_fin': horaFin.text.trim(),
                                    'Ficha_id_ficha': ficha!,
                                    'Usuarios_id_usuarios': instructor!,
                                    'Ambientes_id_ambientes': ambiente!,
                                    'Trimestre_id_trimestre': trimestre!,
                                    'Estado_id_estado': estado!,
                                    'Actividades_id_actividades': actividad!
                                  };
                                  if (editando) data['id'] = '${item['id']}';
                                  await ApiClient.instance.postForm(
                                      editando
                                          ? '/ActualizarProgramacion'
                                          : '/RegistrarProgramacion',
                                      data).timeout(const Duration(seconds: 15));
                                  if (!mounted) return;
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(SnackBar(
                                          content: Text(editando
                                              ? 'Programación actualizada.'
                                              : 'Programación creada.')));
                                  _load();
                                } on ApiException catch (e) {
                                  setModal(() {
                                    guardando = false;
                                    aviso = e.mensaje;
                                  });
                                } on TimeoutException {
                                  setModal(() {
                                    guardando = false;
                                    aviso = 'El servidor tardó demasiado. Inténtalo nuevamente.';
                                  });
                                } catch (_) {
                                  setModal(() {
                                    guardando = false;
                                    aviso =
                                        'No se pudo guardar la programación.';
                                  });
                                }
                              },
                        child: Text(guardando ? 'Guardando...' : 'Guardar'))
                  ],
                )));
    observaciones.dispose();
    fechaInicio.dispose();
    fechaFin.dispose();
    horaInicio.dispose();
    horaFin.dispose();
  }

  Widget _selector(
      String label,
      List<Map<String, dynamic>> datos,
      String? value,
      ValueChanged<String?> alCambiar,
      String Function(Map<String, dynamic>) etiqueta) {
    final valido = datos.any((x) => '${x['id']}' == value);
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
            value: valido ? value : null,
            isExpanded: true,
            decoration: InputDecoration(labelText: label),
            items: datos
                .map((x) => DropdownMenuItem(
                    value: '${x['id']}',
                    child: Text(etiqueta(x), overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: alCambiar));
  }

  Widget _fechaCampo(BuildContext context, String etiqueta,
          TextEditingController controlador) =>
      TextField(
        controller: controlador,
        readOnly: true,
        decoration: InputDecoration(
            labelText: etiqueta,
            suffixIcon: const Icon(Icons.calendar_today_outlined)),
        onTap: () async {
          final fecha = await showDatePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              initialDate: DateTime.now());
          if (fecha != null) {
            controlador.text =
                '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
          }
        },
      );

  Widget _horaCampo(BuildContext context, String etiqueta,
          TextEditingController controlador) =>
      TextField(
        controller: controlador,
        readOnly: true,
        decoration: InputDecoration(
            labelText: etiqueta,
            suffixIcon: const Icon(Icons.schedule_outlined)),
        onTap: () async {
          final hora = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());
          if (hora != null) {
            controlador.text =
                '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
          }
        },
      );

  Future<void> _confirmarEliminar(Map<String, dynamic> item) async {
    final borrar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Eliminar programación'),
                content: const Text(
                    'Esta acción eliminará el horario seleccionado.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'))
                ]));
    if (borrar != true) return;
    try {
      await ApiClient.instance
          .postForm('/EliminarProgramacion', {'id': '${item['id']}'});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Programación eliminada.')));
      _load();
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }
}
