import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});
  @override
  State<RecuperarPasswordScreen> createState() =>
      _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _enviado = false;
  bool _cargando = false;

  void _enviar() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _cargando = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _cargando = false; _enviado = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
          width: 460,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08),
                    blurRadius: 24, offset: const Offset(0, 8))
              ],
            ),
            child: _enviado ? _panelExito() : _formulario(),
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF39A900).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset('assets/images/classcontrol_logo_cropped.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 20),
        Center(child: Text('Recuperar contraseña',
          style: GoogleFonts.dmSans(
              fontSize: 20, fontWeight: FontWeight.w700))),
        const SizedBox(height: 8),
        Center(child: Text(
          'Te enviaremos un enlace para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              fontSize: 13, color: Colors.grey[500]))),
        const SizedBox(height: 24),
        Text('Correo electrónico',
          style: GoogleFonts.dmSans(
              fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail_outline),
            hintText: 'ejemplo@sena.edu.co',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _cargando ? null : _enviar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF39A900),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: _cargando
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text('Enviar enlace de recuperación',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text('Volver al inicio de sesión',
              style: GoogleFonts.dmSans(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _panelExito() {
    return Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF39A900).withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.mark_email_read,
              color: Color(0xFF39A900), size: 36),
        ),
        const SizedBox(height: 20),
        Text('¡Revisa tu correo!',
          style: GoogleFonts.dmSans(
              fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Enviamos el enlace de recuperación a',
          style: GoogleFonts.dmSans(
              fontSize: 13, color: Colors.grey[500])),
        Text(_emailCtrl.text,
          style: GoogleFonts.dmSans(
              fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: Text('Volver al inicio de sesión',
            style: GoogleFonts.dmSans(fontSize: 13)),
        ),
      ],
    );
  }
}
