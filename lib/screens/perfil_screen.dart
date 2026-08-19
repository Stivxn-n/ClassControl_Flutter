import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar.dart';
import '../services/auth_service.dart';
import '../models/usuario_sesion.dart';
import '../widgets/page_header.dart';

class PerfilScreen extends StatefulWidget {
  final String rol;
  const PerfilScreen({super.key, required this.rol});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  UsuarioSesion? _u;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await AuthService.instance.sesionActual();
    if (mounted) setState(() => _u = u);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final u = _u;
    return Scaffold(
        body: Row(children: [
      Sidebar(rol: widget.rol, paginaActual: 'perfil'),
      Expanded(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(
                        title: 'Mi Perfil',
                        subtitle: 'Información de la sesión actual.'),
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: _loading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : u == null
                                    ? const Text(
                                        'La sesión ya no está disponible.')
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            CircleAvatar(
                                                radius: 34,
                                                backgroundColor:
                                                    const Color(0xFFE6F5DF),
                                                child: Text(_iniciales(u),
                                                    style: GoogleFonts.dmSans(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: const Color(
                                                            0xFF248200)))),
                                            const SizedBox(height: 20),
                                            _dato('Nombre',
                                                '${u.nombres} ${u.apellidos}'),
                                            _dato('Usuario', u.username),
                                            _dato('Rol', u.rolNombre),
                                            _dato('ID de usuario',
                                                '${u.idUsuario}'),
                                          ])))
                  ])))
    ]));
  }

  Widget _dato(String a, String b) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(b,
            style:
                GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
      ]));
  String _iniciales(UsuarioSesion u) {
    final nombre = u.nombres.trim(), apellido = u.apellidos.trim();
    return '${nombre.isEmpty ? 'U' : nombre[0]}${apellido.isEmpty ? '' : apellido[0]}'
        .toUpperCase();
  }
}
