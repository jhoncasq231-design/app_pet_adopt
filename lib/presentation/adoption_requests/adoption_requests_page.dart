import 'package:flutter/material.dart';
import '../../core/colors.dart';

class AdoptionRequestsPage extends StatelessWidget {
  const AdoptionRequestsPage({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Aprobada':
        return AppColors.approved;
      case 'Rechazada':
        return AppColors.rejected;
      default:
        return AppColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Solicitudes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Todas'),
              Tab(text: 'Pendientes'),
              Tab(text: 'Aprobadas'),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _RequestCard('Luna', 'Pendiente'),
            _RequestCard('Max', 'Aprobada'),
            _RequestCard('Milo', 'Rechazada'),
          ],
        ),
      ),
    );
  }

  Widget _RequestCard(String petName, String status) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.pets),
        title: Text(petName),
        trailing: Chip(
          label: Text(status),
          backgroundColor: _statusColor(status).withOpacity(0.2),
          labelStyle: TextStyle(color: _statusColor(status)),
        ),
      ),
    );
  }
}
