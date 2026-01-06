import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../home/home_adoptant_page.dart';
import '../map/map_page.dart';
import '../ai_chat/ai_chat_page.dart';
import '../profile/profile_page.dart';
import '../adoption_requests/adoption_requests_page.dart';

class HomeContainerPage extends StatefulWidget {
  const HomeContainerPage({super.key});

  @override
  State<HomeContainerPage> createState() => _HomeContainerPageState();
}

class _HomeContainerPageState extends State<HomeContainerPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeAdoptantPage(), // index 0
          MapPage(), // index 1
          AiChatPage(), // index 2
          AdoptionRequestsPage(), // index 3
          ProfilePage(), // index 4 ✅
        ],
      ),

      // 🔥 TABS COMO EN LA IMAGEN
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
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
