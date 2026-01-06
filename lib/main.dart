import 'package:flutter/material.dart';
import 'presentation/routes/app_routes.dart';
import 'data/services/auth_service.dart';
import 'presentation/login/login_page.dart';
import 'presentation/home/home_container_adoptant_page.dart';
import 'presentation/shelter_admin/home_container_shelter_page.dart';

void main() {
  runApp(const PetAdoptApp());
}

class PetAdoptApp extends StatelessWidget {
  const PetAdoptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const _InitialRoutePage(),
      routes: AppRoutes.routes,
    );
  }
}

// Página que verifica la sesión y redirige
class _InitialRoutePage extends StatefulWidget {
  const _InitialRoutePage();

  @override
  State<_InitialRoutePage> createState() => _InitialRoutePageState();
}

class _InitialRoutePageState extends State<_InitialRoutePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          // Usuario ya está logueado, verificar rol y mostrar la pantalla correspondiente
          final userRole = AuthService.getUserRole();

          if (userRole == 'adoptante') {
            return const HomeContainerAdoptantPage();
          } else if (userRole == 'refugio') {
            return const HomeContainerShelterPage();
          }
        }

        // Usuario no logueado, ir a login
        return const LoginPage();
      },
    );
  }
}
