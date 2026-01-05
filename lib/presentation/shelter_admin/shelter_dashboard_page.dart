import 'package:flutter/material.dart';
import '../../core/colors.dart';

class ShelterDashboardPage extends StatelessWidget {
  const ShelterDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refugio Patitas Felices')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                _SummaryCard('Mascotas', '12'),
                _SummaryCard('Pendientes', '4'),
                _SummaryCard('Adoptadas', '8'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Solicitudes Recientes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Juan Pérez'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 10),
                        Icon(Icons.close, color: Colors.red),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryTeal,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: AppColors.primaryTeal.withOpacity(0.15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
