import 'package:flutter/material.dart';

import '../home/home_adoptant_page.dart';
import '../map/map_page.dart';
import '../ai_chat/ai_chat_page.dart';
import '../adoption_requests/adoption_requests_page.dart';
import '../profile/profile_page.dart';

class HomeContainerAdoptantPage extends StatefulWidget {
  const HomeContainerAdoptantPage({super.key});

  @override
  State<HomeContainerAdoptantPage> createState() =>
      _HomeContainerAdoptantPageState();
}

class _HomeContainerAdoptantPageState
    extends State<HomeContainerAdoptantPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeAdoptantPage(),
    MapPage(),
    AiChatPage(),
    AdoptionRequestsPage(),
     ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
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
