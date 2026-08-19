import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../services/remote_data_service.dart';
import '../widgets/page_header.dart';
import '../widgets/sidebar.dart';

class ReportesScreen extends StatefulWidget {
  final String rol;
  const ReportesScreen({super.key, required this.rol});
  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  String? _descargando;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Row(children: [
          Sidebar(rol: widget.rol, paginaActual: 'reportes'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(
                        title: 'Reportes y Consultas',
                        subtitle:
                            'Genera un archivo CSV con datos reales del sistema.'),
                    LayoutBuilder(
                      builder: (context, constraints) => GridView.count(
                        crossAxisCount: constraints.maxWidth >= 760 ? 2 : 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                        children: [
                          _tarjeta(
                              'fichas',
                              'Reporte de Fichas',
                              'Lista completa de fichas activas e inactivas.',
                              Icons.description,
                              Colors.blue,
                              '/ConsultarFichas'),
                          _tarjeta(
                              'instructores',
                              'Reporte de Instructores',
                              'Listado de usuarios instructores.',
                              Icons.groups,
                              Colors.green,
                              '/ConsultarUsuarios'),
                          _tarjeta(
                              'ambientes',
                              'Reporte de Ambientes',
                              'Estado actual de todos los ambientes.',
                              Icons.meeting_room,
                              Colors.orange,
                              '/ConsultarAmbientes'),
                          _tarjeta(
                              'programacion',
                              'Reporte de Programación',
                              'Horario semanal de clases por instructor.',
                              Icons.calendar_month,
                              Colors.purple,
                              '/ConsultarProgramaciones'),
                          _tarjeta(
                              'competencias',
                              'Reporte de Competencias',
                              'Listado de competencias por programa.',
                              Icons.track_changes,
                              Colors.red,
                              '/ConsultarCompetencias'),
                          _tarjeta(
                              'general',
                              'Reporte General',
                              'Resumen de fichas, usuarios y programación.',
                              Icons.analytics,
                              const Color(0xFF39A900),
                              null),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ]),
      );

  Widget _tarjeta(String id, String titulo, String descripcion, IconData icono,
      Color color, String? endpoint) {
    final descargando = _descargando == id;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)
        ],
      ),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: color.withOpacity(.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: color, size: 24)),
        const SizedBox(width: 16),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text(titulo,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              Text(descripcion,
                  style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ])),
        IconButton(
          tooltip: 'Descargar CSV',
          icon: descargando
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: color))
              : Icon(Icons.download, color: color),
          onPressed:
              descargando ? null : () => _generarReporte(id, titulo, endpoint),
        ),
      ]),
    );
  }

  Future<void> _generarReporte(
      String id, String titulo, String? endpoint) async {
    setState(() => _descargando = id);
    try {
      final datos = endpoint == null
          ? await _datosGenerales()
          : await RemoteDataService.instance.list(endpoint);
      if (datos.isEmpty) throw Exception('No hay registros para este reporte.');
      final csv = _csv(datos);
      final fecha = DateTime.now().toIso8601String().substring(0, 10);
      final archivo = 'classcontrol_${id}_$fecha.csv';
      await Share.shareXFiles([
        XFile.fromData(Uint8List.fromList(utf8.encode('\uFEFF$csv')),
            mimeType: 'text/csv', name: archivo),
      ],
          fileNameOverrides: [archivo],
          subject: titulo,
          text: 'Reporte generado por ClassControl.');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$archivo listo para guardar o compartir.')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _descargando = null);
    }
  }

  Future<List<Map<String, dynamic>>> _datosGenerales() async {
    final grupos = await Future.wait([
      RemoteDataService.instance.list('/ConsultarFichas'),
      RemoteDataService.instance.list('/ConsultarUsuarios'),
      RemoteDataService.instance.list('/ConsultarProgramaciones'),
    ]);
    return [
      {'categoria': 'Fichas', 'cantidad': grupos[0].length},
      {'categoria': 'Usuarios', 'cantidad': grupos[1].length},
      {'categoria': 'Programaciones', 'cantidad': grupos[2].length},
    ];
  }

  String _csv(List<Map<String, dynamic>> datos) {
    final columnas = <String>{for (final fila in datos) ...fila.keys}.toList();
    String escape(Object? valor) =>
        '"${(valor ?? '').toString().replaceAll('"', '""')}"';
    return [
      columnas.map(escape).join(','),
      ...datos.map((fila) => columnas.map((c) => escape(fila[c])).join(',')),
    ].join('\r\n');
  }
}
