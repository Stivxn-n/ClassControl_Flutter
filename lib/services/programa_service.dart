import 'api_client.dart';
import '../models/programa.dart';

class ProgramaService {
  ProgramaService._();
  static final ProgramaService instance = ProgramaService._();

  final _api = ApiClient.instance;

  Future<List<Programa>> listar() async {
    final data = await _api.get('/ConsultarProgramas') as List;
    return data.map((e) => Programa.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> crear(Programa p) => _api.postForm('/RegistrarPrograma', p.toForm());

  Future<void> actualizar(Programa p) => _api.postForm('/ActualizarPrograma', p.toForm());

  Future<void> eliminar(int id) => _api.postForm('/EliminarPrograma', {'id': id.toString()});
}
