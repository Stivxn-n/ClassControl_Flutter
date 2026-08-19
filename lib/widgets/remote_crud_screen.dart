import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_client.dart';
import '../services/remote_data_service.dart';
import 'sidebar.dart';
import 'page_header.dart';

class CrudField {
  final String label;
  final String key;
  final TextInputType keyboardType;
  final bool requiredField;
  final String? optionsEndpoint;
  final String optionLabelKey;

  CrudField(
    this.label,
    this.key, {
    this.keyboardType = TextInputType.text,
    this.requiredField = true,
    this.optionsEndpoint,
    this.optionLabelKey = 'nombre',
  });
}

class RemoteCrudScreen extends StatefulWidget {
  final String rol;
  final String paginaActual;
  final String title;
  final String subtitle;
  final String listEndpoint;
  final String createEndpoint;
  final String updateEndpoint;
  final String deleteEndpoint;
  final List<CrudField> fields;
  final String Function(Map<String, dynamic>) itemTitle;
  final String Function(Map<String, dynamic>) itemSubtitle;
  final Map<String, String> Function(Map<String, String>) buildForm;
  final Widget Function(BuildContext, List<Map<String, dynamic>>)?
      summaryBuilder;

  const RemoteCrudScreen({
    super.key,
    required this.rol,
    required this.paginaActual,
    required this.title,
    required this.subtitle,
    required this.listEndpoint,
    required this.createEndpoint,
    required this.updateEndpoint,
    required this.deleteEndpoint,
    required this.fields,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.buildForm,
    this.summaryBuilder,
  });

  @override
  State<RemoteCrudScreen> createState() => _RemoteCrudScreenState();
}

class _RemoteCrudScreenState extends State<RemoteCrudScreen> {
  final TextEditingController _search = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  final Map<String, List<Map<String, dynamic>>> _opciones = {};

  bool get _canManage => widget.rol == 'admin' || widget.rol == 'coordinador';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final endpoints = widget.fields
          .map((f) => f.optionsEndpoint)
          .whereType<String>()
          .toSet()
          .toList();
      final results = await Future.wait([
        RemoteDataService.instance.list(widget.listEndpoint),
        ...endpoints.map(RemoteDataService.instance.list),
      ]);
      final data = results.first;

      if (mounted) {
        setState(() {
          _items = data;
          for (var i = 0; i < endpoints.length; i++) {
            _opciones[endpoints[i]] = results[i + 1];
          }
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.mensaje;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo conectar con el servidor.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();

    if (q.isEmpty) {
      return _items;
    }

    return _items
        .where(
          (item) => item.values.any(
            (value) => '$value'.toLowerCase().contains(q),
          ),
        )
        .toList();
  }

  Future<void> _form({
    Map<String, dynamic>? item,
  }) async {
    final controllers = <String, TextEditingController>{};

    for (final field in widget.fields) {
      controllers[field.key] = TextEditingController(
        text: item?[field.key]?.toString() ?? '',
      );
    }

    bool saving = false;
    String? error;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return AlertDialog(
            title: Text(
              item == null ? 'Nuevo registro' : 'Editar registro',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final field in widget.fields) ...[
                      if (field.optionsEndpoint == null)
                        TextField(
                          controller: controllers[field.key],
                          keyboardType: field.keyboardType,
                          decoration: InputDecoration(
                            labelText: field.label,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _opciones[field.optionsEndpoint]!.any((x) =>
                                  '${x['id']}' == controllers[field.key]!.text)
                              ? controllers[field.key]!.text
                              : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                              labelText: field.label,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          items: _opciones[field.optionsEndpoint]!
                              .map((x) => DropdownMenuItem(
                                  value: '${x['id']}',
                                  child: Text(
                                      '${x[field.optionLabelKey] ?? x['id']}',
                                      overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (v) => setModal(
                              () => controllers[field.key]!.text = v ?? ''),
                        ),
                      const SizedBox(height: 12),
                    ],
                    if (error != null)
                      Text(
                        error!,
                        style: GoogleFonts.dmSans(
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        for (final field in widget.fields) {
                          final controller = controllers[field.key]!;

                          if (field.requiredField &&
                              controller.text.trim().isEmpty) {
                            setModal(() {
                              error = 'Completa todos los campos.';
                            });
                            return;
                          }
                        }

                        setModal(() {
                          saving = true;
                          error = null;
                        });

                        try {
                          final raw = <String, String>{
                            for (final field in widget.fields)
                              field.key: controllers[field.key]!.text.trim(),
                          };

                          final form = widget.buildForm(raw);

                          if (item != null) {
                            form['id'] = '${item['id']}';
                          }

                          await ApiClient.instance.postForm(
                            item == null
                                ? widget.createEndpoint
                                : widget.updateEndpoint,
                            form,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                          }

                          await _load();
                        } on ApiException catch (e) {
                          setModal(() {
                            saving = false;
                            error = e.mensaje;
                          });
                        } catch (_) {
                          setModal(() {
                            saving = false;
                            error = 'No se pudo guardar el registro.';
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF39A900),
                ),
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );

    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  Future<void> _delete(
    Map<String, dynamic> item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text(
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok != true) {
      return;
    }

    try {
      await ApiClient.instance.postForm(
        widget.deleteEndpoint,
        {
          'id': '${item['id']}',
        },
      );

      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.mensaje),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _filtered;
    final size = MediaQuery.sizeOf(context);
    final compacto = size.width < 760 || size.height < 600;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            rol: widget.rol,
            paginaActual: widget.paginaActual,
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compacto ? 16 : 32,
                    compacto ? 16 : 28,
                    compacto ? 16 : 32,
                    12,
                  ),
                  child: PageHeader(
                    title: widget.title,
                    subtitle: widget.subtitle,
                    action: _canManage
                        ? ElevatedButton.icon(
                            onPressed: () => _form(),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Nuevo',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF39A900)),
                          )
                        : null,
                  ),
                ),
                if (!compacto &&
                    widget.summaryBuilder != null &&
                    !_loading &&
                    _error == null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        compacto ? 16 : 32, 0, compacto ? 16 : 32, 8),
                    child: widget.summaryBuilder!(context, _items),
                  ),
                if (!compacto)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compacto ? 16 : 32,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  ElevatedButton(
                                    onPressed: _load,
                                    child: const Text(
                                      'Reintentar',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: compacto
                                  ? ListView(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 32),
                                      children: [
                                        if (widget.summaryBuilder != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: widget.summaryBuilder!(
                                                context, _items),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: TextField(
                                            controller: _search,
                                            onChanged: (_) => setState(() {}),
                                            decoration: InputDecoration(
                                              prefixIcon:
                                                  const Icon(Icons.search),
                                              hintText: 'Buscar...',
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          ),
                                        ),
                                        for (final item in data)
                                          _itemCard(item),
                                      ],
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.fromLTRB(
                                        compacto ? 16 : 32,
                                        8,
                                        32,
                                        32,
                                      ),
                                      itemCount: data.length,
                                      itemBuilder: (context, i) {
                                        final item = data[i];

                                        return _itemCard(item);
                                      },
                                    ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(Map<String, dynamic> item) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(widget.itemTitle(item),
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          subtitle: Text(widget.itemSubtitle(item),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: _canManage
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _form(item: item)),
                  IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _delete(item)),
                ])
              : null,
        ),
      );
}
