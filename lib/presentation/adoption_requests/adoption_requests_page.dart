import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/services/adoption_request_service.dart';

class AdoptionRequestsPage extends StatefulWidget {
  const AdoptionRequestsPage({super.key});

  @override
  State<AdoptionRequestsPage> createState() => _AdoptionRequestsPageState();
}

class _AdoptionRequestsPageState extends State<AdoptionRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _adoptionService = AdoptionRequestService();
  late Future<List<Map<String, dynamic>>> _allRequests;
  late Future<List<Map<String, dynamic>>> _pendingRequests;
  late Future<List<Map<String, dynamic>>> _approvedRequests;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  void _loadRequests() {
    _allRequests = _adoptionService.getUserAdoptionRequests();
    _pendingRequests = _adoptionService.getRequestsByStatus('pendiente');
    _approvedRequests = _adoptionService.getRequestsByStatus('aprobada');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aprobada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildRequestsList(Future<List<Map<String, dynamic>>> requestsFuture) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadRequests();
        });
      },
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay solicitudes',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final pet = request['pets'] as Map<String, dynamic>?;
              final petName = pet?['nombre'] ?? 'Mascota desconocida';
              final status = (request['estado'] as String? ?? 'pendiente')
                  .toLowerCase();
              final requestDate = request['fecha_solicitud'] as String?;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: pet?['foto_principal'] != null
                            ? Image.network(
                                pet!['foto_principal'] as String,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.pets,
                                size: 32,
                                color: Colors.grey,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              petName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Solicitud: ${_formatDate(requestDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: _statusColor(status),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mis Solicitudes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryTeal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryTeal,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Pendientes'),
            Tab(text: 'Aprobadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList(_allRequests),
          _buildRequestsList(_pendingRequests),
          _buildRequestsList(_approvedRequests),
        ],
      ),
    );
  }
}
