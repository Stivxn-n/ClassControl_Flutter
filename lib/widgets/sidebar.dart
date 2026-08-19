import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/theme_controller.dart';

class Sidebar extends StatelessWidget {
  final String rol;
  final String paginaActual;
  const Sidebar({super.key, required this.rol, required this.paginaActual});

  @override
  Widget build(BuildContext context) {
    // Tablets in portrait also need the compact navigation; the desktop menu
    // leaves too little useful width for tables and forms below this size.
    final size = MediaQuery.sizeOf(context);
    if (size.width < 900 || size.height < 600) return _rail(context);
    return SizedBox(width: 240, child: _menu(context, false));
  }

  Widget _rail(BuildContext context) => Container(
        width: 40,
        color: const Color(0xFF00435E),
        child: SafeArea(
            child: Column(children: [
          IconButton(
              tooltip: 'Abrir menú',
              onPressed: () => _abrirMenu(context),
              icon: const Icon(Icons.menu, color: Colors.white, size: 20)),
          const Divider(height: 1, color: Colors.white24),
          const Spacer(),
          IconButton(
              tooltip: 'Cambiar tema',
              onPressed: ThemeController.instance.toggle,
              icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: Colors.white70,
                  size: 19)),
          IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: Colors.white70, size: 19)),
          const SizedBox(height: 4),
        ])),
      );

  Future<void> _abrirMenu(BuildContext context) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar menú',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, secondary, child) =>
          SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
      pageBuilder: (dialogContext, animation, secondary) => Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
              width: MediaQuery.sizeOf(context).width * .84,
              child: _menu(context, true, dialogContext)),
        ),
      ),
    );
  }

  Widget _menu(BuildContext context, bool movil,
          [BuildContext? dialogContext]) =>
      Material(
        color: Colors.transparent,
        child: Container(
          color: const Color(0xFF00435E),
          child: SafeArea(
              child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 10, 14),
              child: Row(children: [
                Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9)),
                    child: Image.asset(
                        'assets/images/classcontrol_logo_cropped.png',
                        fit: BoxFit.contain)),
                const SizedBox(width: 11),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('ClassControl',
                          style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text('Gestión Educativa',
                          style: GoogleFonts.dmSans(
                              color: const Color(0xFF7BDF47),
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ])),
                if (movil)
                  IconButton(
                      tooltip: 'Cerrar menú',
                      onPressed: () => Navigator.pop(dialogContext!),
                      icon: const Icon(Icons.close, color: Colors.white)),
              ]),
            ),
            const Divider(height: 1, color: Colors.white24),
            Expanded(
                child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                    children: [
                  _item(context, movil, dialogContext, 'Inicio',
                      Icons.dashboard, '/home'),
                  _item(context, movil, dialogContext, 'Fichas',
                      Icons.description, '/fichas'),
                  _item(context, movil, dialogContext, 'Instructores',
                      Icons.groups, '/instructores'),
                  _item(context, movil, dialogContext, 'Programas',
                      Icons.school, '/programas'),
                  _item(context, movil, dialogContext, 'Ambientes',
                      Icons.meeting_room, '/ambientes'),
                  _item(context, movil, dialogContext, 'Competencias',
                      Icons.track_changes, '/competencias'),
                  _item(context, movil, dialogContext, 'Actividades',
                      Icons.assignment_turned_in, '/actividades'),
                  _item(context, movil, dialogContext, 'Programación',
                      Icons.calendar_month, '/programacion'),
                  const Divider(height: 26, color: Colors.white24),
                  _item(context, movil, dialogContext, 'Reportes',
                      Icons.analytics, '/reportes'),
                  if (_puedeGestionarUsuarios)
                    _item(context, movil, dialogContext, 'Usuarios',
                        Icons.manage_accounts, '/usuarios'),
                  _item(context, movil, dialogContext, 'Mi perfil',
                      Icons.person, '/perfil'),
                  const Divider(height: 26, color: Colors.white24),
                  ListTile(
                    dense: true,
                    leading: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: Colors.white70,
                        size: 20),
                    title: Text(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'Modo claro'
                            : 'Modo oscuro',
                        style: GoogleFonts.dmSans(
                            color: Colors.white70, fontSize: 13)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    onTap: ThemeController.instance.toggle,
                  ),
                ])),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
              child: Material(
                  color: const Color(0xFF9B1C1C),
                  borderRadius: BorderRadius.circular(8),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: Text('Cerrar sesión',
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    onTap: () async {
                      if (movil) Navigator.pop(dialogContext!);
                      await _logout(context);
                    },
                  )),
            ),
          ])),
        ),
      );

  Widget _item(BuildContext context, bool movil, BuildContext? dialogContext,
      String label, IconData icon, String ruta) {
    final activo = paginaActual == ruta.replaceAll('/', '');
    return Container(
        margin: const EdgeInsets.only(bottom: 2),
        child: ListTile(
          dense: true,
          leading: Icon(icon,
              color: activo ? Colors.white : Colors.white70, size: 20),
          title: Text(label,
              style: GoogleFonts.dmSans(
                  color: activo ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w400)),
          tileColor: activo ? const Color(0xFF39A900) : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: () {
            if (movil) Navigator.pop(dialogContext!);
            Navigator.pushReplacementNamed(context, ruta, arguments: rol);
          },
        ));
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.instance.logout();
    if (context.mounted)
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  bool get _puedeGestionarUsuarios {
    final valor = rol.toLowerCase();
    return valor == 'admin' ||
        valor == 'administrador' ||
        valor == 'coordinador' ||
        valor == 'coordinacion';
  }
}
