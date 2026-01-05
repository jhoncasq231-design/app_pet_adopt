import 'package:flutter/material.dart';
import '../../core/colors.dart';

class PetDetailPage extends StatelessWidget {
  const PetDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            padding: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () {},
          child: const Text('Solicitar Adopción'),
        ),
      ),
      body: ListView(
        children: [
          Container(
            height: 250,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.pets, size: 80)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Luna - Labrador Retriever',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Chip(label: Text('2 años')),
                    Chip(label: Text('Hembra')),
                    Chip(label: Text('Grande')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
