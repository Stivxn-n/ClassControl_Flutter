import 'package:flutter/material.dart';
import '../widgets/remote_crud_screen.dart';

class CompetenciasScreen extends StatelessWidget {
  final String rol;
  const CompetenciasScreen({super.key, required this.rol});

  @override
  Widget build(BuildContext context) => RemoteCrudScreen(
        rol: rol,
        paginaActual: 'competencias',
        title: 'Gestión de Competencias',
        subtitle: 'Administra las competencias de los programas.',
        listEndpoint: '/ConsultarCompetencias',
        createEndpoint: '/RegistrarCompetencia',
        updateEndpoint: '/ActualizarCompetencia',
        deleteEndpoint: '/EliminarCompetencia',
        fields: [
          CrudField('Código', 'codigo', keyboardType: TextInputType.number),
          CrudField('Descripción', 'descripcion'),
          CrudField('Programa', 'programaId',
              optionsEndpoint: '/ConsultarProgramas', optionLabelKey: 'nombre'),
        ],
        itemTitle: (m) => '${m['codigo']} — ${m['descripcion']}',
        itemSubtitle: (m) => 'Programa asignado: ${m['programaId'] ?? '-'}',
        buildForm: (m) => {
          'codigo_Competencias': m['codigo'] ?? '',
          'descripcion_Competencias': m['descripcion'] ?? '',
          'Programas_idProgramas': m['programaId'] ?? '',
        },
      );
}
