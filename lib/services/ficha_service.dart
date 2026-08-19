import 'api_client.dart';
import '../models/ficha.dart';

class FichaService {
  FichaService._();
  static final FichaService instance = FichaService._();

  final _api = ApiClient.instance;

  Future<List<Ficha>> listar() async {
    final data = await _api.get('/ConsultarFichas') as List;
    return data.map((e) => Ficha.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> crear(Ficha ficha) => _api.postForm('/RegistrarFicha', ficha.toForm());

  Future<void> actualizar(Ficha ficha) => _api.postForm('/ActualizarFicha', ficha.toForm());

  Future<void> eliminar(int id) => _api.postForm('/EliminarFicha', {'id': id.toString()});
}
