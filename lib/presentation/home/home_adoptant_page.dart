import 'package:flutter/material.dart';
import '../../core/colors.dart';

class HomeAdoptantPage extends StatelessWidget {
  const HomeAdoptantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encuentra tu mascota')),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primaryOrange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Chat IA'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Solicitudes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar mascota...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Chip(label: Text('Todos')),
                SizedBox(width: 8),
                Chip(label: Text('Perros')),
                SizedBox(width: 8),
                Chip(label: Text('Gatos')),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (_, index) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.pets)),
                    title: const Text('Luna'),
                    subtitle: const Text('Labrador • 2.5 km'),
                    trailing: Icon(Icons.favorite_border,
                        color: AppColors.primaryOrange),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
