import 'package:flutter/material.dart';
import '../widgets/remote_crud_screen.dart';

class ActividadesScreen extends StatelessWidget {
  final String rol;
  const ActividadesScreen({super.key, required this.rol});

  @override
  Widget build(BuildContext context) => RemoteCrudScreen(
        rol: rol,
        paginaActual: 'actividades',
        title: 'Gestión de Actividades',
        subtitle: 'Administra las actividades de aprendizaje.',
        listEndpoint: '/ConsultarActividades',
        createEndpoint: '/RegistrarActividad',
        updateEndpoint: '/ActualizarActividad',
        deleteEndpoint: '/EliminarActividad',
        fields: [
          CrudField('Código', 'codigoActividad',
              keyboardType: TextInputType.number),
          CrudField('Nombre', 'nombre'),
          CrudField('Descripción', 'descripcion', requiredField: false),
          CrudField('Resultado de aprendizaje', 'resultadoId',
              optionsEndpoint: '/ConsultarResultados',
              optionLabelKey: 'descripcion'),
        ],
        itemTitle: (m) => '${m['codigoActividad']} — ${m['nombre']}',
        itemSubtitle: (m) =>
            '${m['descripcion'] ?? ''}  |  Resultado ID: ${m['resultadoId'] ?? '-'}',
        buildForm: (m) => {
          'codigo_Actividad': m['codigoActividad'] ?? '',
          'nombre_Act': m['nombre'] ?? '',
          'descripcion': m['descripcion'] ?? '',
          'Resultado_aprendizaje_id_resultado_aprendizaje':
              m['resultadoId'] ?? '',
        },
      );
}
