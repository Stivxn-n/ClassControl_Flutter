import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/theme_controller.dart';
import '../widgets/sidebar.dart';

class HomeScreen extends StatefulWidget {
  final String rol;
  const HomeScreen({super.key, required this.rol});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  String _iniciales = 'CC';

  @override
  void initState() {
    super.initState();
    _load();
    _cargarIniciales();
  }

  Future<void> _cargarIniciales() async {
    final usuario = await AuthService.instance.sesionActual();
    if (usuario == null || !mounted) return;
    final nombre = usuario.nombres.trim();
    final apellido = usuario.apellidos.trim();
    setState(() => _iniciales =
        '${nombre.isEmpty ? 'U' : nombre[0]}${apellido.isEmpty ? '' : apellido[0]}'
            .toUpperCase());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ApiClient.instance.get('/ConsultarDashboard');
      if (mounted)
        setState(() => _data = Map<String, dynamic>.from(raw as Map));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cargar el dashboard.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = GoogleFonts.dmSans;
    final d = _data ?? {};
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 850;
    final surface = dark ? const Color(0xFF17272F) : Colors.white;
    final background = dark ? const Color(0xFF101B21) : const Color(0xFFF4F7F8);
    return Scaffold(
      backgroundColor: background,
      body: Row(children: [
        Sidebar(rol: widget.rol, paginaActual: 'home'),
        Expanded(
            child: Column(children: [
          Container(
              height: 64,
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 26),
              color: surface,
              child: Row(children: [
                Text(compact ? 'Inicio' : 'Dashboard Principal',
                    style: text(
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: dark ? Colors.white : const Color(0xFF003D5A))),
                const Spacer(),
                if (!compact)
                  SizedBox(
                    width: 220,
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar actividad, ficha...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDE5EA)),
                        ),
                      ),
                    ),
                  ),
                if (!compact) const SizedBox(width: 14),
                IconButton(
                    tooltip: 'Cambiar modo oscuro',
                    onPressed: ThemeController.instance.toggle,
                    icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color:
                            dark ? Colors.white70 : const Color(0xFF35526A))),
                const SizedBox(width: 8),
                Tooltip(
                    message: 'Mi Perfil',
                    child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => Navigator.pushNamed(context, '/perfil',
                            arguments: widget.rol),
                        child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFE6F5DF),
                            child: Text(_iniciales,
                                style: text(
                                    color: const Color(0xFF248200),
                                    fontWeight: FontWeight.w700))))),
              ])),
          Expanded(
              child: RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(26),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton.icon(
                                onPressed: _showCreateMenu,
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 18),
                                label: Text('Crear registro',
                                    style: text(fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF39A900),
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 19, vertical: 14))),
                            const SizedBox(height: 24),
                            if (_loading)
                              const Center(
                                  child: Padding(
                                      padding: EdgeInsets.all(56),
                                      child: CircularProgressIndicator()))
                            else if (_error != null)
                              _errorCard(text)
                            else ...[
                              LayoutBuilder(builder: (context, c) {
                                final width = c.maxWidth;
                                final columns = width >= 1000
                                    ? 4
                                    : width >= 620
                                        ? 2
                                        : 1;
                                final cards = [
                                  _Metric(
                                      'Fichas activas',
                                      '${d['totalFichasActivas'] ?? 0}',
                                      'Activas',
                                      Icons.description_outlined,
                                      const Color(0xFF39A900),
                                      const Color(0xFFE8F7E2)),
                                  _Metric(
                                      'Ambientes ocupados hoy',
                                      '${d['totalAmbientesHoy'] ?? 0}',
                                      'Hoy',
                                      Icons.meeting_room_outlined,
                                      const Color(0xFF4285F4),
                                      const Color(0xFFE8F0FE)),
                                  _Metric(
                                      'Actividades en curso',
                                      '${d['totalActividadesEnCurso'] ?? 0}',
                                      'En progreso',
                                      Icons.assignment_turned_in_outlined,
                                      const Color(0xFFFF7A21),
                                      const Color(0xFFFFF0E6)),
                                  _Metric(
                                      'Instructores activos',
                                      '${d['totalInstructores'] ?? 0}',
                                      'Activos',
                                      Icons.group_outlined,
                                      const Color(0xFF9B51E0),
                                      const Color(0xFFF4EAFF)),
                                ];
                                return GridView.count(
                                    crossAxisCount: columns,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: columns == 1 ? 2.0 : 1.45,
                                    children: cards
                                        .map((m) => _metricCard(m, text))
                                        .toList());
                              }),
                              const SizedBox(height: 24),
                              LayoutBuilder(
                                  builder: (context, c) => c.maxWidth > 850
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: _occupationCard(text)),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                  flex: 2,
                                                  child: _programCard(text, d))
                                            ])
                                      : Column(children: [
                                          _occupationCard(text),
                                          const SizedBox(height: 16),
                                          _programCard(text, d)
                                        ])),
                            ],
                          ])))),
        ])),
      ]),
    );
  }

  Future<void> _showCreateMenu() async {
    final pages =
        <({String title, String detail, IconData icon, String route})>[
      (
        title: 'Nueva ficha',
        detail: 'Crear una ficha de formación.',
        icon: Icons.description_outlined,
        route: '/fichas'
      ),
      (
        title: 'Nuevo programa',
        detail: 'Crear un programa de formación.',
        icon: Icons.school_outlined,
        route: '/programas'
      ),
      (
        title: 'Nuevo ambiente',
        detail: 'Registrar un ambiente.',
        icon: Icons.meeting_room_outlined,
        route: '/ambientes'
      ),
      (
        title: 'Nueva actividad',
        detail: 'Registrar actividad de aprendizaje.',
        icon: Icons.assignment_turned_in_outlined,
        route: '/actividades'
      ),
      if (widget.rol == 'admin')
        (
          title: 'Nuevo usuario',
          detail: 'Crear usuario en el sistema.',
          icon: Icons.person_add_alt_1_outlined,
          route: '/registrar_usuario'
        ),
    ];
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * .72),
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Crear registro',
                      style: GoogleFonts.dmSans(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Elige el tipo de registro que deseas crear.',
                      style: GoogleFonts.dmSans(color: Colors.grey)),
                  const SizedBox(height: 12),
                  for (final page in pages)
                    ListTile(
                      leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE6F5DF),
                          child:
                              Icon(page.icon, color: const Color(0xFF248200))),
                      title: Text(page.title,
                          style:
                              GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
                      subtitle: Text(page.detail,
                          style: GoogleFonts.dmSans(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, page.route,
                            arguments: widget.rol);
                      },
                    ),
                ]))),
      )),
    );
  }

  Widget _errorCard(
          TextStyle Function(
                  {Color? color, double? fontSize, FontWeight? fontWeight})
              text) =>
      Card(
          child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 42, color: Color(0xFF6B7A89)),
                const SizedBox(height: 12),
                Text(_error!, style: text(color: const Color(0xFF52606D))),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'))
              ]))));

  Widget _metricCard(
          _Metric m,
          TextStyle Function(
                  {Color? color, double? fontSize, FontWeight? fontWeight})
              text) =>
      Card(
          elevation: 1,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: m.tint,
                              borderRadius: BorderRadius.circular(9)),
                          child: Icon(m.icon, color: m.color)),
                      const Spacer(),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                              color: m.tint,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(m.tag,
                              style: text(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: m.color)))
                    ]),
                    const Spacer(),
                    Text(m.title,
                        style:
                            text(fontSize: 13, color: const Color(0xFF52606D))),
                    const SizedBox(height: 4),
                    Text(m.value,
                        style: text(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF003D5A)))
                  ])));

  Widget _occupationCard(
          TextStyle Function(
                  {Color? color, double? fontSize, FontWeight? fontWeight})
              text) =>
      _panel(
          text,
          'Ocupación de Ambientes',
          const Center(
              child: Text(
                  'La ocupación se mostrará al consultar la programación.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF718096)))));

  Widget _programCard(
          TextStyle Function(
                  {Color? color, double? fontSize, FontWeight? fontWeight})
              text,
          Map<String, dynamic> d) =>
      _panel(
          text,
          'Estado de Programas',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final item in (d['estadoProgramas'] as List? ?? []).take(4))
              Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text('${item['programa'] ?? 'Programa'}',
                      style: text(fontSize: 13, fontWeight: FontWeight.w600))),
            if ((d['estadoProgramas'] as List? ?? []).isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Sin datos de programas.',
                      style: TextStyle(color: Color(0xFF718096)))),
            const SizedBox(height: 5),
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/reportes',
                        arguments: widget.rol),
                    child: const Text('Ver todos los reportes')))
          ]));

  Widget _panel(
      TextStyle Function(
              {Color? color, double? fontSize, FontWeight? fontWeight})
          text,
      String title,
      Widget body) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        height: 315,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: dark ? const Color(0xFF17272F) : Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
                color:
                    dark ? const Color(0xFF29414C) : const Color(0xFFE0E7EB))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: text(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: dark ? Colors.white : const Color(0xFF003D5A))),
          const SizedBox(height: 16),
          Expanded(child: body)
        ]));
  }
}

class _Metric {
  final String title, value, tag;
  final IconData icon;
  final Color color, tint;
  const _Metric(
      this.title, this.value, this.tag, this.icon, this.color, this.tint);
}
