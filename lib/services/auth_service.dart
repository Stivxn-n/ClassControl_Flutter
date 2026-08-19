import 'api_client.dart';
import '../models/usuario_sesion.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _api = ApiClient.instance;

  /// Llama a POST /Iniciar (Servlet.Inicio_Sesion). Lanza ApiException
  /// con el mensaje del backend si el usuario/clave estan mal, o si el
  /// usuario esta inactivo.
  Future<UsuarioSesion> login(String username, String clave) async {
    final data = await _api.postForm('/Iniciar', {
      'username': username,
      'clave': clave,
    });
    return UsuarioSesion.fromJson(data as Map<String, dynamic>);
  }

  /// Registro publico (aprendiz/instructor). [rol] debe ser 1 (instructor)
  /// o 2 (aprendiz), igual que en RegistrarUsuario.java.
  Future<void> registrar({
    required String nombres,
    required String apellidos,
    required String identificacion,
    required String correo,
    required String telefono,
    required String username,
    required String clave,
    required int tipoDoc,
    required int rol,
    String fechaNacimiento = '',
    String direccion = '',
    String nivelEducativo = '',
    String profesion = '',
  }) async {
    await _api.postForm('/RegistrarUsuario', {
      'nombres': nombres,
      'apellidos': apellidos,
      'identificacion': identificacion,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'username': username,
      'clave': clave,
      'nivel_Educativo': nivelEducativo,
      'profesion': profesion,
      'fecha_Nacimiento': fechaNacimiento,
      'tipoVinculacion': '1',
      'tipoDoc': tipoDoc.toString(),
      'rol': rol.toString(),
    });
  }

  Future<void> registrarUsuarioAdmin({
    required String nombres,
    required String apellidos,
    required String identificacion,
    required String correo,
    required String telefono,
    required String username,
    required String clave,
    required int tipoDoc,
    required int rol,
    required String fechaNacimiento,
    String nivelEducativo = '',
    String profesion = '',
    String direccion = '',
  }) async {
    await _api.postForm('/RegistrarUsuarioAdmin', {
      'nombres': nombres,
      'apellidos': apellidos,
      'identificacion': identificacion,
      'correo': correo,
      'telefono': telefono,
      'username': username,
      'clave': clave,
      'direccion': direccion,
      'nivel_Educativo': nivelEducativo,
      'profesion': profesion,
      'tipoDoc': '$tipoDoc',
      'rol': '$rol',
      'activo': 'true',
      'fecha_Nacimiento': fechaNacimiento,
      'tipoVinculacion': '1',
    });
  }

  /// Al abrir la app: revisa si la cookie guardada todavia tiene una
  /// sesion valida en el servidor. Si no hay sesion, devuelve null
  /// (sin lanzar error) para mandar al usuario al login.
  Future<UsuarioSesion?> sesionActual() async {
    await _api.cargarCookieGuardada();
    try {
      final data = await _api.get('/api/SesionActual');
      return UsuarioSesion.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      // Sin conexión, CORS bloqueado o sesión vencida: la pantalla inicial
      // debe continuar al login en vez de terminar la aplicación.
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _api.postForm('/api/CerrarSesion', {});
    } finally {
      await _api.limpiarCookie();
    }
  }
}
