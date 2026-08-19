import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _verPass = false;
  bool _recordarme = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _cargando = true; _error = null; });
    try {
      final usuario = await AuthService.instance.login(_usuarioCtrl.text.trim(), _passCtrl.text);
      if (mounted) Navigator.pushReplacementNamed(context, '/home', arguments: usuario.rolCorto);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  InputDecoration _input(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
    hintText: hint, prefixIcon: Icon(icon, color: const Color(0xFF5D765D)), suffixIcon: suffix,
    filled: true, fillColor: const Color(0xFFF8FAF7), contentPadding: const EdgeInsets.symmetric(vertical: 17),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDCE5D6))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDCE5D6))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF39A900), width: 1.5)),
  );

  @override
  Widget build(BuildContext context) {
    final text = GoogleFonts.dmSans;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: Stack(children: [
        const Positioned(top: -150, right: -150, child: _Glow()),
        const Positioned(bottom: -190, left: -150, child: _Glow()),
        Center(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.white, elevation: 12, shadowColor: Colors.black26,
                  child: Column(children: [
                    Container(
                      width: double.infinity, padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
                      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF39A900), Color(0xFF258400)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                      child: Column(children: [
                        Container(width: 144, height: 110, padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Image.asset('assets/images/classcontrol_logo_cropped.png', fit: BoxFit.contain)),
                        const SizedBox(height: 15),
                        Text('ClassControl', style: text(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text('Gestión de Programación de Instructores', textAlign: TextAlign.center, style: text(fontSize: 13, color: Colors.white.withOpacity(.88), fontWeight: FontWeight.w500)),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
                      child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Iniciar sesión', style: text(fontSize: 19, fontWeight: FontWeight.w700, color: const Color(0xFF1D2B1D))),
                        const SizedBox(height: 4),
                        Text('Ingresa tus credenciales para acceder', style: text(fontSize: 13, color: const Color(0xFF718071))),
                        const SizedBox(height: 22),
                        Text('Correo electrónico o Usuario', style: text(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF526452))),
                        const SizedBox(height: 7),
                        TextFormField(controller: _usuarioCtrl, textInputAction: TextInputAction.next, decoration: _input('ejemplo@sena.edu.co', Icons.person_outline), validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa tu correo o usuario.' : null),
                        const SizedBox(height: 16),
                        Text('Contraseña', style: text(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF526452))),
                        const SizedBox(height: 7),
                        TextFormField(controller: _passCtrl, obscureText: !_verPass, onFieldSubmitted: (_) => _login(), decoration: _input('••••••••', Icons.lock_outline, suffix: IconButton(icon: Icon(_verPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF5D765D)), onPressed: () => setState(() => _verPass = !_verPass))), validator: (v) => v == null || v.isEmpty ? 'Ingresa tu contraseña.' : null),
                        const SizedBox(height: 8),
                        Row(children: [
                          SizedBox(width: 24, height: 24, child: Checkbox(value: _recordarme, activeColor: const Color(0xFF39A900), onChanged: (v) => setState(() => _recordarme = v ?? false))),
                          Text('Recordarme', style: text(fontSize: 13, color: const Color(0xFF718071))), const Spacer(),
                          TextButton(onPressed: () => Navigator.pushNamed(context, '/recuperar'), child: Text('¿Olvidaste tu contraseña?', style: text(fontSize: 13, color: const Color(0xFF39A900), fontWeight: FontWeight.w700))),
                        ]),
                        if (_error != null) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.error_outline, color: Color(0xFFC62828)), const SizedBox(width: 8), Expanded(child: Text(_error!, style: text(fontSize: 13, color: const Color(0xFFC62828))))]))],
                        const SizedBox(height: 18),
                        SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(onPressed: _cargando ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF39A900), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), icon: _cargando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.login), label: Text(_cargando ? 'Ingresando...' : 'Iniciar sesión', style: text(fontWeight: FontWeight.w700)))),
                      ])),
                    ),
                    Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEF2EA)))), child: Center(child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [Text('¿No tienes una cuenta? ', style: text(fontSize: 13, color: const Color(0xFF718071))), TextButton(onPressed: () => Navigator.pushNamed(context, '/registrar'), child: Text('Registrarse como nuevo usuario', style: text(fontSize: 13, color: const Color(0xFF39A900), fontWeight: FontWeight.w700)))]))),
                  ]),
                ),
              ),
              const SizedBox(height: 22),
              Text('© 2024 Servicio Nacional de Aprendizaje SENA.\nTodos los derechos reservados.', textAlign: TextAlign.center, style: text(fontSize: 11, color: const Color(0xFF718071))),
            ]),
          ),
        )),
      ]),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow();
  @override
  Widget build(BuildContext context) => Container(width: 420, height: 420, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x1939A900)));
}
