import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'presentation/routes/app_routes.dart';
import 'presentation/login/login_page.dart';
import 'presentation/home/home_container_adoptant_page.dart';
import 'presentation/shelter_admin/home_container_shelter_page.dart';
import 'presentation/login/role_selection_google_page.dart'; // Asegúrate de crear este page

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    await dotenv.load(fileName: ".env-example");
  }

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const PetAdoptApp());
}

class PetAdoptApp extends StatelessWidget {
  const PetAdoptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Adopt',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const _InitialRoutePage(),
      routes: AppRoutes.routes,
    );
  }
}

// --------------------
// Página inicial (Splash + verificación de sesión)
// --------------------
class _InitialRoutePage extends StatefulWidget {
  const _InitialRoutePage();

  @override
  State<_InitialRoutePage> createState() => _InitialRoutePageState();
}

class _InitialRoutePageState extends State<_InitialRoutePage> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _subscribeAuthChanges();
    _checkAuthState();
  }

  // Escucha cambios de sesión para manejar OAuth Web
  void _subscribeAuthChanges() {
    supabase.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session == null) return;

      final userId = session.user.id;

      final profile = await supabase
          .from('profiles')
          .select('rol')
          .eq('id', userId)
          .maybeSingle();

      if (!mounted) return;

      if (profile == null) {
        Navigator.of(context).pushReplacementNamed('/select-role');
      } else {
        final userRole = profile['rol'];
        if (userRole == 'adoptante') {
          Navigator.of(context).pushReplacementNamed('/home-adoptant');
        } else {
          Navigator.of(context).pushReplacementNamed('/home-shelter');
        }
      }
    });
  }

  // Verifica sesión al inicio
  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final session = supabase.auth.currentSession;

    if (session != null) {
      final userId = session.user.id;

      final profile = await supabase
          .from('profiles')
          .select('rol')
          .eq('id', userId)
          .maybeSingle();

      if (!mounted) return;

      if (profile == null) {
        Navigator.of(context).pushReplacementNamed('/select-role');
      } else {
        final userRole = profile['rol'];
        if (userRole == 'adoptante') {
          Navigator.of(context).pushReplacementNamed('/home-adoptant');
        } else {
          Navigator.of(context).pushReplacementNamed('/home-shelter');
        }
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.pets, size: 60, color: Colors.teal),
            ),
            const SizedBox(height: 30),
            const Text(
              'Pet Adopt',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Encuentra tu compañero perfecto',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
