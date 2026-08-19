import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar.dart';
import '../models/ficha.dart';
import '../models/catalogo_item.dart';
import '../services/ficha_service.dart';
import '../services/catalogo_service.dart';
import '../services/api_client.dart';
import '../widgets/page_header.dart';

class FichasScreen extends StatefulWidget {
  final String rol;
  const FichasScreen({super.key, required this.rol});
  @override
  State<FichasScreen> createState() => _FichasScreenState();
}

class _FichasScreenState extends State<FichasScreen> {
  final _busqueda = TextEditingController();
  int _pagina = 0;
  final int _porPagina = 8;

  bool _cargando = true;
  String? _error;
  List<Ficha> _fichas = [];

  // Catalogos para mostrar nombres en la tabla y llenar los selects del modal.
  List<CatalogoItem> _programas = [];
  List<CatalogoItem> _jornadas = [];
  List<CatalogoItem> _modalidades = [];
  List<CatalogoItem> _niveles = [];
  List<CatalogoItem> _sedes = [];
  List<CatalogoItem> _estados = [];
  List<CatalogoItem> _etapas = [];

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final catalogo = CatalogoService.instance;
      final resultados = await Future.wait([
        FichaService.instance.listar(),
        catalogo.programas(),
        catalogo.jornadas(),
        catalogo.modalidades(),
        catalogo.niveles(),
        catalogo.sedes(),
        catalogo.estados(),
        catalogo.etapas(),
      ]);
      setState(() {
        _fichas = resultados[0] as List<Ficha>;
        _programas = resultados[1] as List<CatalogoItem>;
        _jornadas = resultados[2] as List<CatalogoItem>;
        _modalidades = resultados[3] as List<CatalogoItem>;
        _niveles = resultados[4] as List<CatalogoItem>;
        _sedes = resultados[5] as List<CatalogoItem>;
        _estados = resultados[6] as List<CatalogoItem>;
        _etapas = resultados[7] as List<CatalogoItem>;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } catch (e) {
      setState(() => _error = 'No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _nombre(List<CatalogoItem> lista, int id) => lista
      .firstWhere((e) => e.id == id,
          orElse: () => CatalogoItem(id: id, etiqueta: '—'))
      .etiqueta;

  List<Ficha> get _fichasFiltradas {
    final busq = _busqueda.text.toLowerCase();
    if (busq.isEmpty) return _fichas;
    return _fichas.where((f) {
      return f.codigo.toString().contains(busq) ||
          _nombre(_programas, f.programaId).toLowerCase().contains(busq);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(rol: widget.rol, paginaActual: 'fichas'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarTodo,
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _vistaError()
                      : _vistaContenido(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vistaError() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.cloud_off, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Center(
          child: Text(_error!,
              style: GoogleFonts.dmSans(color: Colors.red.shade600),
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: _cargarTodo,
            child: Text('Reintentar', style: GoogleFonts.dmSans()),
          ),
        ),
      ],
    );
  }

  Widget _vistaContenido() {
    final fichas = _fichasFiltradas;
    final totalPaginas =
        (fichas.length / _porPagina).ceil().clamp(1, 999).toInt();
    final fichasPagina =
        fichas.skip(_pagina * _porPagina).take(_porPagina).toList();
    final surface = Theme.of(context).cardColor;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          (MediaQuery.sizeOf(context).width < 900 ||
                  MediaQuery.sizeOf(context).height < 600)
              ? 16
              : 32,
          (MediaQuery.sizeOf(context).width < 900 ||
                  MediaQuery.sizeOf(context).height < 600)
              ? 16
              : 28,
          (MediaQuery.sizeOf(context).width < 900 ||
                  MediaQuery.sizeOf(context).height < 600)
              ? 16
              : 32,
          32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
              title: 'Gestión de Fichas',
              subtitle: 'Administra las fichas de formación activas.',
              action: (widget.rol == 'admin' || widget.rol == 'coordinador')
                  ? ElevatedButton.icon(
                      onPressed: () => _mostrarModal(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text('Nueva ficha',
                          style: GoogleFonts.dmSans(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39A900),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))))
                  : null),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: TextField(
              controller: _busqueda,
              onChanged: (_) => setState(() => _pagina = 0),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar por codigo o programa...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              children: [
                if (MediaQuery.sizeOf(context).width >= 900 &&
                    MediaQuery.sizeOf(context).height >= 600)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF20343E)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        _th('Codigo', 1),
                        _th('Programa', 3),
                        _th('Nivel', 1),
                        _th('Aprendices', 1),
                        _th('Estado', 1),
                        if (widget.rol == 'admin' ||
                            widget.rol == 'coordinador')
                          _th('Acciones', 1),
                      ],
                    ),
                  ),
                if (fichasPagina.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('No hay fichas registradas.',
                        style: GoogleFonts.dmSans(color: Colors.grey)),
                  ),
                ...fichasPagina.map((f) => _fila(context, f)),
                if (totalPaginas > 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mostrando ${_pagina * _porPagina + 1}-${(_pagina * _porPagina + fichasPagina.length)} de ${fichas.length}',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: Colors.grey[500]),
                        ),
                        Row(
                          children: List.generate(
                            totalPaginas,
                            (i) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: TextButton(
                                onPressed: () => setState(() => _pagina = i),
                                style: TextButton.styleFrom(
                                  backgroundColor: _pagina == i
                                      ? const Color(0xFF39A900)
                                      : null,
                                  minimumSize: const Size(36, 36),
                                ),
                                child: Text('${i + 1}',
                                    style: GoogleFonts.dmSans(
                                        color: _pagina == i
                                            ? Colors.white
                                            : null)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String label, int flex) {
    return Expanded(
      flex: flex,
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600])),
    );
  }

  Widget _fila(BuildContext context, Ficha f) {
    final estadoTexto = _nombre(_estados, f.estadoId);
    final activa = estadoTexto.toLowerCase().contains('activ') &&
        !estadoTexto.toLowerCase().contains('inactiv');
    if (MediaQuery.sizeOf(context).width < 900 ||
        MediaQuery.sizeOf(context).height < 600) {
      return Card(
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: ListTile(
          title: Text('Ficha ${f.codigo}',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w800)),
          subtitle: Text(
              '${_nombre(_programas, f.programaId)}\n${_nombre(_niveles, f.nivelFormacionId)} · ${f.cantidadAprendices} aprendices · $estadoTexto',
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          isThreeLine: true,
          trailing: widget.rol == 'admin' || widget.rol == 'coordinador'
              ? Wrap(children: [
                  IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 18, color: Colors.blue),
                      onPressed: () => _mostrarModal(context, ficha: f)),
                  IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: Colors.red),
                      onPressed: () => _confirmarEliminar(context, f)),
                ])
              : null,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text('${f.codigo}',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(
              flex: 3,
              child: Text(_nombre(_programas, f.programaId),
                  style: GoogleFonts.dmSans(fontSize: 13))),
          Expanded(
              flex: 1,
              child: Text(_nombre(_niveles, f.nivelFormacionId),
                  style: GoogleFonts.dmSans(fontSize: 13))),
          Expanded(
              flex: 1,
              child: Text('${f.cantidadAprendices}',
                  style: GoogleFonts.dmSans(fontSize: 13))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activa
                    ? const Color(0xFF39A900).withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(estadoTexto,
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: activa ? const Color(0xFF39A900) : Colors.red,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          if (widget.rol == 'admin' || widget.rol == 'coordinador')
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 18, color: Colors.blue),
                    onPressed: () => _mostrarModal(context, ficha: f),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    onPressed: () => _confirmarEliminar(context, f),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _mostrarModal(BuildContext context, {Ficha? ficha}) {
    final codigoCtrl =
        TextEditingController(text: ficha?.codigo.toString() ?? '');
    final aprendicesCtrl = TextEditingController(
        text: ficha?.cantidadAprendices.toString() ?? '0');
    int? programaId = ficha?.programaId ??
        (_programas.isNotEmpty ? _programas.first.id : null);
    int? jornadaId =
        ficha?.jornadaId ?? (_jornadas.isNotEmpty ? _jornadas.first.id : null);
    int? modalidadId = ficha?.modalidadId ??
        (_modalidades.isNotEmpty ? _modalidades.first.id : null);
    int? nivelId = ficha?.nivelFormacionId ??
        (_niveles.isNotEmpty ? _niveles.first.id : null);
    int? sedeId = ficha?.sedeId ?? (_sedes.isNotEmpty ? _sedes.first.id : null);
    int? estadoId =
        ficha?.estadoId ?? (_estados.isNotEmpty ? _estados.first.id : null);
    int? etapaId =
        ficha?.etapaId ?? (_etapas.isNotEmpty ? _etapas.first.id : null);
    DateTime? fechaInicio = ficha?.fechaInicio;
    DateTime? fechaFin = ficha?.fechaFin;
    bool guardando = false;
    String? errorModal;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => AlertDialog(
          title: Text(ficha == null ? 'Nueva Ficha' : 'Editar Ficha',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codigoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Codigo',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: aprendicesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad de aprendices',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dropdown('Programa', _programas, programaId,
                      (v) => setModal(() => programaId = v)),
                  const SizedBox(height: 12),
                  _dropdown('Jornada', _jornadas, jornadaId,
                      (v) => setModal(() => jornadaId = v)),
                  const SizedBox(height: 12),
                  _dropdown('Modalidad', _modalidades, modalidadId,
                      (v) => setModal(() => modalidadId = v)),
                  const SizedBox(height: 12),
                  _dropdown('Nivel de formacion', _niveles, nivelId,
                      (v) => setModal(() => nivelId = v)),
                  const SizedBox(height: 12),
                  _dropdown('Sede', _sedes, sedeId,
                      (v) => setModal(() => sedeId = v)),
                  const SizedBox(height: 12),
                  _dropdown('Estado', _estados, estadoId,
                      (v) => setModal(() => estadoId = v)),
                  const SizedBox(height: 12),
                  _dropdown('Etapa', _etapas, etapaId,
                      (v) => setModal(() => etapaId = v)),
                  const SizedBox(height: 12),
                  _fechaField(context, 'Fecha de inicio', fechaInicio,
                      (fecha) => setModal(() => fechaInicio = fecha)),
                  const SizedBox(height: 12),
                  _fechaField(context, 'Fecha de finalización', fechaFin,
                      (fecha) => setModal(() => fechaFin = fecha)),
                  if (errorModal != null) ...[
                    const SizedBox(height: 12),
                    Text(errorModal!,
                        style: GoogleFonts.dmSans(
                            color: Colors.red, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: guardando ? null : () => Navigator.pop(context),
                child: Text('Cancelar', style: GoogleFonts.dmSans())),
            ElevatedButton(
              onPressed: guardando
                  ? null
                  : () async {
                      if (codigoCtrl.text.trim().isEmpty ||
                          programaId == null ||
                          jornadaId == null ||
                          modalidadId == null ||
                          nivelId == null ||
                          sedeId == null ||
                          estadoId == null ||
                          etapaId == null ||
                          fechaInicio == null ||
                          fechaFin == null) {
                        setModal(
                            () => errorModal = 'Completa todos los campos.');
                        return;
                      }
                      setModal(() {
                        guardando = true;
                        errorModal = null;
                      });
                      try {
                        final nueva = Ficha(
                          id: ficha?.id ?? 0,
                          codigo: int.parse(codigoCtrl.text.trim()),
                          cantidadAprendices:
                              int.tryParse(aprendicesCtrl.text.trim()) ?? 0,
                          programaId: programaId!,
                          jornadaId: jornadaId!,
                          modalidadId: modalidadId!,
                          nivelFormacionId: nivelId!,
                          sedeId: sedeId!,
                          estadoId: estadoId!,
                          etapaId: etapaId!,
                          fechaInicio: fechaInicio,
                          fechaFin: fechaFin,
                        );
                        if (ficha == null) {
                          await FichaService.instance.crear(nueva);
                        } else {
                          await FichaService.instance.actualizar(nueva);
                        }
                        if (context.mounted) Navigator.pop(context);
                        await _cargarTodo();
                      } on ApiException catch (e) {
                        setModal(() {
                          guardando = false;
                          errorModal = e.mensaje;
                        });
                      } catch (e) {
                        setModal(() {
                          guardando = false;
                          errorModal = 'No se pudo guardar la ficha.';
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39A900)),
              child: guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Guardar',
                      style: GoogleFonts.dmSans(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fechaField(BuildContext context, String etiqueta, DateTime? valor,
      ValueChanged<DateTime> onSelected) {
    final texto = valor == null
        ? 'Seleccionar fecha'
        : valor.toIso8601String().split('T').first;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final fecha = await showDatePicker(
          context: context,
          initialDate: valor ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (fecha != null) onSelected(fecha);
      },
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: etiqueta,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 18),
          const SizedBox(width: 10),
          Text(texto)
        ]),
      ),
    );
  }

  Widget _dropdown(String label, List<CatalogoItem> items, int? valor,
      ValueChanged<int?> onChanged) {
    return DropdownButtonFormField<int>(
      value: valor,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map((e) => DropdownMenuItem(
              value: e.id,
              child: Text(e.etiqueta,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(fontSize: 13))))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _confirmarEliminar(BuildContext context, Ficha ficha) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar Ficha',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('Esta accion no se puede deshacer.',
            style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.dmSans())),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FichaService.instance.eliminar(ficha.id);
                await _cargarTodo();
              } on ApiException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.mensaje)));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar',
                style: GoogleFonts.dmSans(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
