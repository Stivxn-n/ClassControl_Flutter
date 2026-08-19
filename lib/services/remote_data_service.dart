import 'api_client.dart';

/// Servicio sencillo para las pantallas que consumen listados JSON del backend.
class RemoteDataService {
  RemoteDataService._();
  static final RemoteDataService instance = RemoteDataService._();

  final ApiClient _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> list(String endpoint) async {
    final data = await _api.get(endpoint);
    if (data is! List) return <Map<String, dynamic>>[];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
