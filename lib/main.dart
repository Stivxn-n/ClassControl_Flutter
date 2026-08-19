import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'services/theme_controller.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recuperar_password_screen.dart';
import 'screens/fichas_screen.dart';
import 'screens/instructores_screen.dart';
import 'screens/programas_screen.dart';
import 'screens/competencias_screen.dart';
import 'screens/actividades_screen.dart';
import 'screens/programacion_screen.dart';
import 'screens/reportes_screen.dart';
import 'screens/usuarios_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/ambientes_screen.dart';
import 'screens/registrar_usuario_screen.dart';

void main() {
  runApp(const ClassControlApp());
}

class ClassControlApp extends StatelessWidget {
  const ClassControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) => MaterialApp(
        title: 'ClassControl',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF39A900),
            primary: const Color(0xFF39A900),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F7F8),
          textTheme: GoogleFonts.dmSansTextTheme(),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 1,
            shadowColor: Colors.black12,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDE5EA))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDE5EA))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF39A900), width: 1.5)),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF61C83A), brightness: Brightness.dark),
          scaffoldBackgroundColor: const Color(0xFF101B21),
          textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
          cardTheme: CardThemeData(
              color: const Color(0xFF17272F),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF17272F),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          useMaterial3: true,
        ),
        themeMode: mode,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final rol = settings.arguments as String? ?? 'aprendiz';
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => HomeScreen(rol: rol));
            case '/recuperar':
              return MaterialPageRoute(
                  builder: (_) => const RecuperarPasswordScreen());
            case '/fichas':
              return MaterialPageRoute(builder: (_) => FichasScreen(rol: rol));
            case '/instructores':
              return MaterialPageRoute(
                  builder: (_) => InstructoresScreen(rol: rol));
            case '/programas':
              return MaterialPageRoute(
                  builder: (_) => ProgramasScreen(rol: rol));
            case '/competencias':
              return MaterialPageRoute(
                  builder: (_) => CompetenciasScreen(rol: rol));
            case '/actividades':
              return MaterialPageRoute(
                  builder: (_) => ActividadesScreen(rol: rol));
            case '/programacion':
              return MaterialPageRoute(
                  builder: (_) => ProgramacionScreen(rol: rol));
            case '/reportes':
              return MaterialPageRoute(
                  builder: (_) => ReportesScreen(rol: rol));
            case '/usuarios':
              return MaterialPageRoute(
                  builder: (_) => UsuariosScreen(rol: rol));
            case '/perfil':
              return MaterialPageRoute(builder: (_) => PerfilScreen(rol: rol));
            case '/ambientes':
              return MaterialPageRoute(
                  builder: (_) => AmbientesScreen(rol: rol));
            case '/registrar_usuario':
              return MaterialPageRoute(
                  builder: (_) => RegistrarUsuarioScreen(rol: rol));
            case '/registrar':
              return MaterialPageRoute(
                  builder: (_) => const RegistrarUsuarioScreen(
                      rol: 'publico', publico: true));
            default:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        },
      ),
    );
  }
}

/// Al abrir la app, pregunta al backend si la cookie de sesion guardada
/// sigue siendo valida. Si lo es, entra directo a Home; si no, al login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificar();
  }

  Future<void> _verificar() async {
    final usuario = await AuthService.instance.sesionActual();
    if (!mounted) return;
    if (usuario != null) {
      Navigator.pushReplacementNamed(context, '/home',
          arguments: usuario.rolCorto);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F4FF),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
