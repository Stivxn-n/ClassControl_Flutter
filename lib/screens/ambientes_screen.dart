import 'package:flutter/material.dart';
import '../widgets/remote_crud_screen.dart';
import '../widgets/donut_chart.dart';

class AmbientesScreen extends StatelessWidget {
  final String rol;
  const AmbientesScreen({super.key, required this.rol});

  @override
  Widget build(BuildContext context) => RemoteCrudScreen(
        rol: rol,
        paginaActual: 'ambientes',
        title: 'Gestión de Ambientes',
        subtitle: 'Administra los ambientes y su capacidad.',
        listEndpoint: '/ConsultarAmbientes',
        createEndpoint: '/RegistrarAmbiente',
        updateEndpoint: '/ActualizarAmbiente',
        deleteEndpoint: '/EliminarAmbiente',
        fields: [
          CrudField('Descripción', 'descripcion'),
          CrudField('Capacidad', 'capacidad',
              keyboardType: TextInputType.number),
          CrudField('Sede', 'sedeId',
              optionsEndpoint: '/ConsultarSedes', optionLabelKey: 'nombre'),
        ],
        itemTitle: (m) => '${m['descripcion']}',
        itemSubtitle: (m) =>
            'Capacidad: ${m['capacidad'] ?? '-'}  |  Sede ID: ${m['sedeId'] ?? '-'}',
        buildForm: (m) => {
          'descripcion_Ambiente': m['descripcion'] ?? '',
          'capacidad': m['capacidad'] ?? '',
          'Sede_id_sede': m['sedeId'] ?? '',
        },
        summaryBuilder: _resumen,
      );

  Widget _resumen(BuildContext context, List<Map<String, dynamic>> items) {
    final total = items.length;
    final capacidad = items.fold<int>(
        0, (s, x) => s + ((x['capacidad'] as num?)?.toInt() ?? 0));
    final sedes = items
        .map((x) => '${x['sedeId'] ?? ''}')
        .where((x) => x.isNotEmpty)
        .toSet()
        .length;
    final promedio = total == 0 ? 0 : (capacidad / total).round();
    Widget dato(String numero, String etiqueta, IconData icono) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(icono, color: const Color(0xFF39A900)),
            const SizedBox(width: 9),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(numero,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(etiqueta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11))
                ]))
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LayoutBuilder(builder: (context, c) {
        // Phone screens still have room for two compact indicators.
        final columns = c.maxWidth >= 860
            ? 4
            : c.maxWidth >= 300
                ? 2
                : 1;
        final cards = [
          dato('$total', 'Total de ambientes', Icons.meeting_room),
          dato('$capacidad', 'Capacidad total', Icons.groups),
          dato('$sedes', 'Sedes con ambientes', Icons.location_city),
          dato('$promedio', 'Capacidad promedio', Icons.analytics)
        ];
        return GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 3.8 : 1.75,
            children: cards);
      }),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Distribución de capacidad',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          DonutChart(
              centerLabel: 'Capacidad\ntotal',
              centerValue: '$capacidad',
              data: [
                for (var i = 0; i < items.take(6).length; i++)
                  DonutSlice(
                      '${items[i]['descripcion'] ?? 'Ambiente'}',
                      ((items[i]['capacidad'] as num?)?.toDouble() ?? 0)
                          .clamp(0, double.infinity),
                      const [
                        Color(0xFF39A900),
                        Color(0xFF4285F4),
                        Color(0xFFFF7A21),
                        Color(0xFF9B51E0),
                        Color(0xFFE0439E),
                        Color(0xFF00B8A9)
                      ][i % 6]),
              ]),
        ]),
      ),
    ]);
  }
}
