import 'package:flutter/material.dart';

import 'shelter_dashboard_page.dart';
import '../shelter_admin/shelter_adoption_requests_page.dart';

import '../profile/refugio_profile_page.dart';

class HomeContainerShelterPage extends StatefulWidget {
  const HomeContainerShelterPage({super.key});

  @override
  State<HomeContainerShelterPage> createState() =>
      _HomeContainerShelterPageState();
}

class _HomeContainerShelterPageState extends State<HomeContainerShelterPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      ShelterDashboardPage(),
      ShelterAdoptionRequestsPage(),
      RefugioProfilePage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
