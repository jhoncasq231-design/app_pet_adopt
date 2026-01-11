import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'presentation/routes/app_routes.dart';
import 'presentation/login/login_page.dart';
import 'presentation/home/home_container_adoptant_page.dart';
import 'presentation/shelter_admin/home_container_shelter_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Si falta .env, intentar cargar desde .env-example
    try {
      await dotenv.load(fileName: ".env-example");
    } catch (e2) {
      print('Error cargando variables de entorno: $e2');
    }
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final supabase = Supabase.instance.client;

    try {
      final session = supabase.auth.currentSession;

      if (session != null) {
        final userId = session.user.id;

        final response = await supabase
            .from('profiles')
            .select('rol')
            .eq('id', userId)
            .single();

        final userRole = response['rol'];

        if (!mounted) return;

        if (userRole == 'adoptante') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const HomeContainerAdoptantPage(),
            ),
          );
        } else if (userRole == 'refugio') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeContainerShelterPage()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      } else {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (e) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
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
