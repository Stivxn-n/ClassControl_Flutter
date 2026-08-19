import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar.dart';
import '../models/programa.dart';
import '../services/programa_service.dart';
import '../services/api_client.dart';
import '../widgets/page_header.dart';

class ProgramasScreen extends StatefulWidget {
  final String rol;
  const ProgramasScreen({super.key, required this.rol});
  @override
  State<ProgramasScreen> createState() => _ProgramasScreenState();
}

class _ProgramasScreenState extends State<ProgramasScreen> {
  final _busqueda = TextEditingController();
  bool _cargando = true;
  String? _error;
  List<Programa> _programas = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await ProgramaService.instance.listar();
      setState(() => _programas = lista);
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } catch (e) {
      setState(() => _error = 'No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<Programa> get _filtrados {
    final busq = _busqueda.text.toLowerCase();
    if (busq.isEmpty) return _programas;
    return _programas
        .where((p) =>
            p.nombre.toLowerCase().contains(busq) ||
            p.codigo.toString().contains(busq))
        .toList();
  }

  bool get _puedeGestionar =>
      widget.rol == 'admin' || widget.rol == 'coordinador';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(rol: widget.rol, paginaActual: 'programas'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargar,
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
                textAlign: TextAlign.center)),
        const SizedBox(height: 12),
        Center(
            child: ElevatedButton(
                onPressed: _cargar,
                child: Text('Reintentar', style: GoogleFonts.dmSans()))),
      ],
    );
  }

  Widget _vistaContenido() {
    final lista = _filtrados;
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
              title: 'Gestión de Programas',
              subtitle: 'Administra la oferta educativa.',
              action: _puedeGestionar
                  ? ElevatedButton.icon(
                      onPressed: () => _mostrarModal(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text('Nuevo programa',
                          style: GoogleFonts.dmSans(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39A900),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))))
                  : null),
          TextField(
            controller: _busqueda,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar por codigo o nombre...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          ...lista.map((p) => _fila(context, p)),
          if (lista.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No se encontraron programas.',
                    style: GoogleFonts.dmSans(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fila(BuildContext context, Programa p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(p.nombre,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        subtitle: Text('Codigo: ${p.codigo}',
            style: GoogleFonts.dmSans(fontSize: 12)),
        trailing: _puedeGestionar
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 18, color: Colors.blue),
                    onPressed: () => _mostrarModal(context, programa: p),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    onPressed: () => _confirmarEliminar(context, p),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _mostrarModal(BuildContext context, {Programa? programa}) {
    final codigoCtrl =
        TextEditingController(text: programa?.codigo.toString() ?? '');
    final nombreCtrl = TextEditingController(text: programa?.nombre ?? '');
    bool guardando = false;
    String? errorModal;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => AlertDialog(
          title: Text(programa == null ? 'Nuevo Programa' : 'Editar Programa',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codigoCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Codigo',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nombreCtrl,
                decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              if (errorModal != null) ...[
                const SizedBox(height: 12),
                Text(errorModal!,
                    style: GoogleFonts.dmSans(color: Colors.red, fontSize: 13)),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: guardando ? null : () => Navigator.pop(context),
                child: Text('Cancelar', style: GoogleFonts.dmSans())),
            ElevatedButton(
              onPressed: guardando
                  ? null
                  : () async {
                      final codigo = int.tryParse(codigoCtrl.text.trim());
                      if (codigo == null || nombreCtrl.text.trim().isEmpty) {
                        setModal(
                            () => errorModal = 'Completa todos los campos.');
                        return;
                      }
                      setModal(() {
                        guardando = true;
                        errorModal = null;
                      });
                      try {
                        final nuevo = Programa(
                            id: programa?.id ?? 0,
                            codigo: codigo,
                            nombre: nombreCtrl.text.trim());
                        if (programa == null) {
                          await ProgramaService.instance.crear(nuevo);
                        } else {
                          await ProgramaService.instance.actualizar(nuevo);
                        }
                        if (context.mounted) Navigator.pop(context);
                        await _cargar();
                      } on ApiException catch (e) {
                        setModal(() {
                          guardando = false;
                          errorModal = e.mensaje;
                        });
                      } catch (e) {
                        setModal(() {
                          guardando = false;
                          errorModal = 'No se pudo guardar el programa.';
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

  void _confirmarEliminar(BuildContext context, Programa programa) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar Programa',
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
                await ProgramaService.instance.eliminar(programa.id);
                await _cargar();
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
