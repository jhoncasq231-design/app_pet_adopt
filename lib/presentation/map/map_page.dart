import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/shelter.dart';
import '../../data/services/map_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? userLocation;

  final MapService _mapService = MapService();

  bool isLoading = true;

  List<Shelter> shelters = [];
  List<Shelter> filteredShelters = [];

  /// 🔥 REFUGIOS MOCK (ECUADOR)
  final List<Shelter> mockShelters = [
    Shelter(
      id: 'mock-1',
      nombre: 'Refugio Patitas Felices',
      direccion: 'Quito - Centro',
      lat: -0.180653,
      long: -78.467834,
    ),
    Shelter(
      id: 'mock-2',
      nombre: 'Huellitas del Sur',
      direccion: 'Guayaquil',
      lat: -2.170998,
      long: -79.922359,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    await _getUserLocation();
    await _loadShelters();
  }

  /// 📍 OBTENER UBICACIÓN DEL USUARIO
  Future<void> _getUserLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        userLocation = const LatLng(-0.180653, -78.467834);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        userLocation = const LatLng(-0.180653, -78.467834);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      userLocation = LatLng(position.latitude, position.longitude);
    } catch (_) {
      /// 🛟 Fallback Quito
      userLocation = const LatLng(-0.180653, -78.467834);
    }
  }

  /// 🏠 CARGAR REFUGIOS (SUPABASE + MOCKS)
  Future<void> _loadShelters() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase.from('shelters').select();

      final List<Shelter> apiShelters = [];

      for (final item in response) {
        try {
          apiShelters.add(Shelter.fromMap(item));
        } catch (e) {
          debugPrint('⚠️ Refugio ignorado (sin GPS): $e');
        }
      }

      shelters = [...mockShelters, ...apiShelters];
      filteredShelters = shelters;
    } catch (e) {
      debugPrint('❌ Error cargando refugios: $e');
      shelters = mockShelters;
      filteredShelters = mockShelters;
    }

    setState(() => isLoading = false);
  }

  /// 🔍 BUSCAR REFUGIO (CENTRA MAPA + ZOOM)
  void _searchShelter(String value) {
    if (value.trim().isEmpty) {
      setState(() => filteredShelters = shelters);
      return;
    }

    final results = shelters
        .where((s) => s.nombre.toLowerCase().contains(value.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el refugio')),
      );
      return;
    }

    final shelter = results.first;

    _mapController.move(LatLng(shelter.lat, shelter.long), 15);

    setState(() {
      filteredShelters = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Refugios')),
      body: Column(
        children: [
          /// 🔍 BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              onChanged: _searchShelter,
              decoration: InputDecoration(
                hintText: 'Buscar refugio por nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          /// 🗺️ MAPA
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userLocation!,
                initialZoom: 13,
              ),
              children: [
                /// 🌍 OPENSTREETMAP
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.amikuna.app',
                ),

                /// 📍 USUARIO
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 36,
                      ),
                    ),
                  ],
                ),

                /// 🏠 REFUGIOS
                MarkerLayer(
                  markers: filteredShelters.map((shelter) {
                    return Marker(
                      point: LatLng(shelter.lat, shelter.long),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          final distance = Geolocator.distanceBetween(
                            userLocation!.latitude,
                            userLocation!.longitude,
                            shelter.lat,
                            shelter.long,
                          );

                          _showShelterInfo(shelter, distance / 1000);
                        },
                        child: const Icon(
                          Icons.pets,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShelterInfo(Shelter shelter, double distanceKm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            children: [
              // Icono refugio
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pets, color: Colors.teal, size: 30),
              ),

              const SizedBox(width: 12),

              // Info refugio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shelter.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shelter.direccion ?? 'Sin dirección',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _infoChip(
                          '${distanceKm.toStringAsFixed(1)} km',
                          Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        _infoChip('15 mascotas', Colors.teal),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón navegación
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.navigation, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _infoChip(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
    ),
  );
}
