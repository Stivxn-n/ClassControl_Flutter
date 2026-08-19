import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

/// Excepción con el mensaje que ya viene traducido desde el backend
/// (campo "error" del JSON), lista para mostrar en un SnackBar/Dialog.
class ApiException implements Exception {
  final int statusCode;
  final String mensaje;
  ApiException(this.statusCode, this.mensaje);
  @override
  String toString() => mensaje;
}

/// Cliente HTTP compartido por todos los servicios (FichasService,
/// AuthService, etc). Se encarga de:
///  - Mandar siempre "Accept: application/json" para que el backend
///    responda JSON en vez de redirigir a un .jsp.
///  - Guardar y reenviar la cookie JSESSIONID que crea el servlet de
///    login, para que la sesión se mantenga entre peticiones.
///  - Parsear la respuesta y lanzar ApiException si algo falla.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _cookie;
  final http.Client _client = createHttpClient();

  /// Carga la cookie guardada (si el usuario ya había iniciado sesión
  /// y cerró la app sin cerrar sesión).
  Future<void> cargarCookieGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    _cookie = prefs.getString('session_cookie');
  }

  Future<void> _guardarCookie(http.Response response) async {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      // Solo nos interesa el par JSESSIONID=xxxx, sin los atributos
      // (Path, HttpOnly, etc).
      _cookie = setCookie.split(';').first;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_cookie', _cookie!);
    }
  }

  Future<void> limpiarCookie() async {
    _cookie = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
  }

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (_cookie != null) 'Cookie': _cookie!,
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$kBaseUrl$path').replace(queryParameters: query);

  /// GET a un endpoint Consultar* -> devuelve la lista/objeto ya decodificado.
  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await _client.get(_uri(path, query), headers: _headers);
    return _procesar(res);
  }

  /// POST tipo formulario a Registrar*/Actualizar*/Eliminar*/Iniciar.
  Future<dynamic> postForm(String path, Map<String, String> campos) async {
    final res = await _client.post(
      _uri(path),
      headers: _headers,
      body: campos,
    );
    await _guardarCookie(res);
    return _procesar(res);
  }

  dynamic _procesar(http.Response res) {
    dynamic body;
    try {
      body = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      body = null;
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    final mensaje = (body is Map && body['error'] != null)
        ? body['error'].toString()
        : 'Error de conexion con el servidor (${res.statusCode}).';
    throw ApiException(res.statusCode, mensaje);
  }
}
