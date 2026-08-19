import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar.dart';
import '../services/remote_data_service.dart';
import '../services/api_client.dart';
import '../widgets/page_header.dart';

class UsuariosScreen extends StatefulWidget {
  final String rol;
  const UsuariosScreen({super.key, required this.rol});
  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _search = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  Map<int, String> _roles = {};
  int? _rolFiltro;
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await RemoteDataService.instance.list('/ConsultarUsuarios');
      final roles = await RemoteDataService.instance.list('/ConsultarRoles');
      _roles = {
        for (final r in roles) (r['id'] as num).toInt(): '${r['descripcion']}'
      };
      if (mounted) setState(() => _items = users);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cargar los usuarios.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolSesion = widget.rol.toLowerCase();
    final puedeGestionar = rolSesion == 'admin' ||
        rolSesion == 'administrador' ||
        rolSesion == 'coordinador' ||
        rolSesion == 'coordinacion';
    if (!puedeGestionar)
      return Scaffold(
          body: Row(children: [
        Sidebar(rol: widget.rol, paginaActual: 'usuarios'),
        const Expanded(
            child: Center(
                child: Text(
                    'Solo administración y coordinación pueden gestionar usuarios.')))
      ]));
    final q = _search.text.toLowerCase();
    final data = _items.where((u) {
      final s =
          '${u['nombres']} ${u['apellidos']} ${u['correo']} ${u['username']}';
      final coincideTexto = q.isEmpty || s.toLowerCase().contains(q);
      final coincideRol =
          _rolFiltro == null || (u['rolId'] as num?)?.toInt() == _rolFiltro;
      return coincideTexto && coincideRol;
    }).toList();
    return Scaffold(
        body: Row(children: [
      Sidebar(rol: widget.rol, paginaActual: 'usuarios'),
      Expanded(
          child: Column(children: [
        Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.sizeOf(context).width < 760 ? 16 : 32,
                MediaQuery.sizeOf(context).width < 760 ? 16 : 28,
                MediaQuery.sizeOf(context).width < 760 ? 16 : 32,
                0),
            child: PageHeader(
                title: 'Gestión de Usuarios',
                subtitle: 'Activa, inactiva o retira usuarios del sistema.',
                action: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/registrar_usuario',
                          arguments: widget.rol);
                      _load();
                    },
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text('Nuevo usuario',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF39A900))))),
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width < 760 ? 16 : 32,
                vertical: 8),
            child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))))),
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width < 760 ? 16 : 32,
                vertical: 0),
            child: DropdownButtonFormField<int?>(
                value: _rolFiltro,
                isExpanded: true,
                decoration: InputDecoration(
                    labelText: 'Filtrar por rol',
                    prefixIcon: const Icon(Icons.filter_list),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('Todos los roles')),
                  ..._roles.entries.map((r) => DropdownMenuItem<int?>(
                      value: r.key,
                      child: Text(r.value, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) => setState(() => _rolFiltro = v))),
        Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_error!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _load, child: const Text('Reintentar'))
                      ]))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                                MediaQuery.sizeOf(context).width < 760
                                    ? 16
                                    : 32,
                                8,
                                MediaQuery.sizeOf(context).width < 760
                                    ? 16
                                    : 32,
                                32),
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final u = data[i];
                              final activo = u['activo'] == true;
                              return Card(
                                  child: ListTile(
                                leading: CircleAvatar(
                                    child: Text('${u['nombres'] ?? '?'}'.isEmpty
                                        ? '?'
                                        : '${u['nombres']}'
                                            .substring(0, 1)
                                            .toUpperCase())),
                                title: Text(
                                    '${u['nombres'] ?? ''} ${u['apellidos'] ?? ''}',
                                    style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    '${u['correo'] ?? '-'} • ${u['username'] ?? '-'} • ${_roles[(u['rolId'] as num?)?.toInt()] ?? 'Rol ${u['rolId'] ?? '-'}'}'),
                                trailing: Wrap(spacing: 4, children: [
                                  Tooltip(
                                      message: activo
                                          ? 'Inactivar usuario'
                                          : 'Activar usuario',
                                      child: IconButton(
                                          icon: Icon(
                                              activo
                                                  ? Icons.toggle_on
                                                  : Icons.toggle_off,
                                              color: activo
                                                  ? const Color(0xFF39A900)
                                                  : Colors.grey,
                                              size: 30),
                                          onPressed: () =>
                                              _cambiarEstado(u, !activo))),
                                  IconButton(
                                      tooltip: 'Eliminar usuario',
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => _eliminar(u)),
                                ]),
                              ));
                            })))
      ]))
    ]));
  }

  Future<void> _cambiarEstado(Map<String, dynamic> u, bool activo) async {
    try {
      await ApiClient.instance.postForm('/ActualizarUsuario', {
        'id': '${u['id']}',
        'nombres': '${u['nombres'] ?? ''}',
        'apellidos': '${u['apellidos'] ?? ''}',
        'identificacion': '${u['identificacion'] ?? ''}',
        'correo': '${u['correo'] ?? ''}',
        'telefono': '${u['telefono'] ?? ''}',
        'direccion': '${u['direccion'] ?? ''}',
        'username': '${u['username'] ?? ''}',
        'nivel_Educativo': '${u['nivelEducativo'] ?? ''}',
        'profesion': '${u['profesion'] ?? ''}',
        'rol': '${u['rolId']}',
        'tipoDoc': '${u['tipoDocumentoId']}',
        'tipoVinculacion': '${u['tipoVinculacionId']}',
        'activo': '$activo',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(activo ? 'Usuario activado.' : 'Usuario inactivado.')));
        _load();
      }
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }

  Future<void> _eliminar(Map<String, dynamic> u) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Eliminar usuario'),
                content: Text(
                    '¿Eliminar a ${u['nombres']} ${u['apellidos']}? Esta acción no se puede deshacer.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Eliminar'))
                ]));
    if (ok != true) return;
    try {
      await ApiClient.instance
          .postForm('/EliminarUsuario', {'id': '${u['id']}'});
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Usuario eliminado.')));
        _load();
      }
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }
}
