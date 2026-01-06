import 'package:flutter/material.dart';

import 'shelter_dashboard_page.dart';
import '../adoption_requests/adoption_requests_page.dart';

class HomeContainerShelterPage extends StatefulWidget {
  const HomeContainerShelterPage({super.key});

  @override
  State<HomeContainerShelterPage> createState() =>
      _HomeContainerShelterPageState();
}

class _HomeContainerShelterPageState
    extends State<HomeContainerShelterPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ShelterDashboardPage(),
    AdoptionRequestsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Panel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Solicitudes',
          ),
        ],
      ),
    );
  }
}
