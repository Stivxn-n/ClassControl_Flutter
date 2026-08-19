import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class RegistrarScreen extends StatefulWidget {
  const RegistrarScreen({super.key});
  @override
  State<RegistrarScreen> createState() => _RegistrarScreenState();
}

class _RegistrarScreenState extends State<RegistrarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _verPass = false;
  bool _verConfirm = false;
  bool _cargando = false;

  void _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Las contrasenas no coinciden', style: GoogleFonts.dmSans()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      await AuthService.instance.registrar(
        nombres: _nombresCtrl.text.trim(),
        apellidos: _apellidosCtrl.text.trim(),
        identificacion: _documentoCtrl.text.trim(),
        correo: _emailCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        clave: _passCtrl.text,
        tipoDoc: 1,
        rol: 2,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cuenta creada correctamente. Ya puedes iniciar sesion.',
              style: GoogleFonts.dmSans()),
          backgroundColor: const Color(0xFF39A900),
        ),
      );
      Navigator.pop(context);
    } on ApiException catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.mensaje), backgroundColor: Colors.red),
      );
    } catch(_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar la cuenta.'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF39A900),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(7),
                child: Image.asset('assets/images/classcontrol_logo_cropped.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              Text(
                'Crear cuenta',
                style: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              Text(
                'Registrate como aprendiz en ClassControl',
                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 28),
              Container(
                width: 440,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _campo(
                              'Nombres',
                              _nombresCtrl,
                              validator: (v) =>
                                  v!.length < 2 ? 'Minimo 2 caracteres' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _campo(
                              'Apellidos',
                              _apellidosCtrl,
                              validator: (v) =>
                                  v!.length < 2 ? 'Minimo 2 caracteres' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _campo(
                        'Numero de documento',
                        _documentoCtrl,
                        tipo: TextInputType.number,
                        validator: (v) =>
                            v!.length < 6 ? 'Documento invalido' : null,
                      ),
                      const SizedBox(height: 14),
                      _campo(
                        'Correo electronico',
                        _emailCtrl,
                        tipo: TextInputType.emailAddress,
                        validator: (v) =>
                            !v!.contains('@') ? 'Correo invalido' : null,
                      ),
                      const SizedBox(height: 14),
                      _campo(
                        'Telefono',
                        _telefonoCtrl,
                        tipo: TextInputType.phone,
                        validator: (v) =>
                            v!.length < 7 ? 'Telefono invalido' : null,
                      ),
                      const SizedBox(height: 14),
                      _campo(
                        'Nombre de usuario',
                        _usernameCtrl,
                        validator: (v) =>
                            v!.length < 4 ? 'Minimo 4 caracteres' : null,
                      ),
                      const SizedBox(height: 14),
                      _campoPass(
                        'Contrasena',
                        _passCtrl,
                        _verPass,
                        () => setState(() => _verPass = !_verPass),
                      ),
                      const SizedBox(height: 14),
                      _campoPass(
                        'Confirmar contrasena',
                        _confirmCtrl,
                        _verConfirm,
                        () => setState(() => _verConfirm = !_verConfirm),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _registrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF39A900),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Crear cuenta',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            '¿Ya tienes cuenta? Iniciar sesion',
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFF39A900),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController ctrl, {
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _campoPass(
    String label,
    TextEditingController ctrl,
    bool ver,
    VoidCallback toggle,
  ) {
    return TextFormField(
      controller: ctrl,
      obscureText: !ver,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(ver ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: toggle,
        ),
      ),
      validator: (v) => v!.length < 8 ? 'Minimo 8 caracteres' : null,
    );
  }
}
