import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../data/services/adoption_request_service.dart';

class ShelterAdoptionRequestsPage extends StatefulWidget {
  const ShelterAdoptionRequestsPage({super.key});

  @override
  State<ShelterAdoptionRequestsPage> createState() =>
      _ShelterAdoptionRequestsPageState();
}

class _ShelterAdoptionRequestsPageState
    extends State<ShelterAdoptionRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _adoptionService = AdoptionRequestService();
  late Future<List<Map<String, dynamic>>> _shelterRequests;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _shelterRequests = _adoptionService.getShelterAdoptionRequests();
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

  Future<void> _showRequestDetails(Map<String, dynamic> request) async {
    final petData = request['pets'] as Map<String, dynamic>?;
    final userData = request['profiles'] as Map<String, dynamic>?;
    final petName = petData?['nombre'] ?? 'Mascota desconocida';
    final userName = userData?['nombre'] ?? 'Usuario desconocido';
    final userEmail = userData?['email'] ?? 'N/A';
    final userPhone = userData?['telefono'] ?? 'N/A';
    final userLocation = userData?['ubicacion'] ?? 'N/A';
    final status = (request['estado'] as String? ?? 'pendiente').toLowerCase();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de la Solicitud',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Mascota', petName),
            _buildDetailRow('Solicitante', userName),
            _buildDetailRow('Email', userEmail),
            _buildDetailRow('Teléfono', userPhone),
            _buildDetailRow('Ubicación', userLocation),
            _buildDetailRow('Estado', status.toUpperCase()),
            _buildDetailRow(
              'Fecha Solicitud',
              _formatDate(request['fecha_solicitud'] as String?),
            ),
            const SizedBox(height: 20),
            if (status == 'pendiente')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _approveRequest(request['id'] as String);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _rejectRequest(request['id'] as String);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Rechazar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveRequest(String requestId) async {
    final success = await _adoptionService.approveAdoptionRequest(requestId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Solicitud aprobada' : 'Error al aprobar la solicitud',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      setState(() {
        _shelterRequests = _adoptionService.getShelterAdoptionRequests();
      });
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    final success = await _adoptionService.rejectAdoptionRequest(requestId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Solicitud rechazada' : 'Error al rechazar la solicitud',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      setState(() {
        _shelterRequests = _adoptionService.getShelterAdoptionRequests();
      });
    }
  }

  Widget _buildRequestsList(List<Map<String, dynamic>> allRequests) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _shelterRequests = _adoptionService.getShelterAdoptionRequests();
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allRequests.length,
        itemBuilder: (context, index) {
          final request = allRequests[index];
          final petData = request['pets'] as Map<String, dynamic>?;
          final userData = request['profiles'] as Map<String, dynamic>?;
          final petName = petData?['nombre'] ?? 'Mascota desconocida';
          final userName = userData?['nombre'] ?? 'Usuario desconocido';
          final status = (request['estado'] as String? ?? 'pendiente')
              .toLowerCase();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.pets, color: Colors.grey),
              ),
              title: Text(
                petName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Por: $userName',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Chip(
                label: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: _statusColor(status),
              ),
              onTap: () => _showRequestDetails(request),
            ),
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
          'Solicitudes de Adopción',
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _shelterRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allRequests = snapshot.data ?? [];

          if (allRequests.isEmpty) {
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

          final pendingRequests = allRequests
              .where(
                (r) =>
                    (r['estado'] as String? ?? '').toLowerCase() == 'pendiente',
              )
              .toList();
          final approvedRequests = allRequests
              .where(
                (r) =>
                    (r['estado'] as String? ?? '').toLowerCase() == 'aprobada',
              )
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(allRequests),
              _buildRequestsList(pendingRequests),
              _buildRequestsList(approvedRequests),
            ],
          );
        },
      ),
    );
  }
}
