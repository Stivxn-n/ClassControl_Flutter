import 'api_client.dart';
import '../models/catalogo_item.dart';

/// Trae las listas de apoyo que usan los formularios (selects) de
/// Fichas, Programación, etc. Cada metodo llama a un endpoint
/// Consultar* que ya devuelve JSON en el backend.
class CatalogoService {
  CatalogoService._();
  static final CatalogoService instance = CatalogoService._();

  final _api = ApiClient.instance;

  Future<List<CatalogoItem>> _lista(String path) async {
    final data = await _api.get(path) as List;
    return data
        .map((e) => CatalogoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CatalogoItem>> programas() => _lista('/ConsultarProgramas');
  Future<List<CatalogoItem>> jornadas() => _lista('/ConsultarJornadas');
  Future<List<CatalogoItem>> modalidades() => _lista('/ConsultarModalidades');
  Future<List<CatalogoItem>> niveles() => _lista('/ConsultarNiveles');
  Future<List<CatalogoItem>> sedes() => _lista('/ConsultarSedes');
  Future<List<CatalogoItem>> estados() => _lista('/ConsultarEstados');
  Future<List<CatalogoItem>> etapas() => _lista('/ConsultarEtapas');
}
