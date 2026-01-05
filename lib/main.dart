import 'package:flutter/material.dart';
import 'core/colors.dart';
import 'presentation/login/role_selection_page.dart';

void main() {
  runApp(const PetAdoptApp());
}

class PetAdoptApp extends StatelessWidget {
  const PetAdoptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetAdopt',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorSchemeSeed: AppColors.primaryOrange,
      ),
      home: const RoleSelectionPage(),
    );
  }
}
