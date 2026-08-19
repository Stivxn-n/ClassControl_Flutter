/// Representa al usuario actualmente logueado (lo que devuelve
/// /Iniciar y /api/SesionActual).
class UsuarioSesion {
  final int idUsuario;
  final String nombres;
  final String apellidos;
  final String username;
  final int rolId;
  final String rolNombre;

  UsuarioSesion({
    required this.idUsuario,
    required this.nombres,
    required this.apellidos,
    required this.username,
    required this.rolId,
    required this.rolNombre,
  });

  factory UsuarioSesion.fromJson(Map<String, dynamic> json) {
    return UsuarioSesion(
      idUsuario: json['idUsuario'] as int,
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      username: json['username'] ?? '',
      rolId: json['rolId'] as int,
      rolNombre: json['rolNombre'] ?? '',
    );
  }

  /// El resto de la app (Sidebar, rutas, permisos) usa un rol en
  /// minusculas y sin tildes: 'admin', 'coordinador', 'instructor', 'aprendiz'.
  /// Ajusta este mapeo a como esten escritos los roles en tu tabla `roles`.
  String get rolCorto {
    final r = rolNombre.toLowerCase();
    if (r.contains('admin')) return 'admin';
    if (r.contains('coordinador')) return 'coordinador';
    if (r.contains('instructor')) return 'instructor';
    return 'aprendiz';
  }
}
