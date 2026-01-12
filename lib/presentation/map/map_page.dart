import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importante
import '../../data/models/shelter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Shelter> _sheltersFromDb = []; // Lista para los datos de Supabase
  LatLng? _userLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSheltersAndLocation();
  }

  // 1. CARGAR DATOS DE SUPABASE Y UBICACIÓN
  Future<void> _fetchSheltersAndLocation() async {
    try {
      // Obtener refugios de Supabase
      final response = await supabase.from('shelters').select('id, nombre, direccion, lat, long');
      
      // Obtener ubicación GPS
      Position position = await Geolocator.getCurrentPosition();
      
      if (mounted) {
        setState(() {
          _sheltersFromDb = (response as List).map((s) => Shelter.fromMap(s)).toList();
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController.move(_userLocation!, 14.0);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. CÁLCULO DE DISTANCIA
  String _getDistance(double lat, double long) {
    if (_userLocation == null) return "...";
    double meters = Geolocator.distanceBetween(
      _userLocation!.latitude, _userLocation!.longitude, lat, long);
    return meters < 1000 ? "${meters.toStringAsFixed(0)}m" : "${(meters/1000).toStringAsFixed(1)}km";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAPA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-0.1806, -78.4678),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  // Mi ubicación
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                  // MARCADORES DINÁMICOS DESDE SUPABASE
                  ..._sheltersFromDb.map((shelter) => Marker(
                    point: LatLng(shelter.lat, shelter.long),
                    child: GestureDetector(
                      onTap: () => _showShelterInfo(shelter),
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  )).toList(),
                ],
              ),
            ],
          ),

          // Indicador de carga
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.orange)),

          // Buscador (Diseño previo)
          Positioned(
            top: 50, left: 20, right: 20,
            child: _buildSearchBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Buscar refugios...",
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.orange),
        ),
      ),
    );
  }

  void _showShelterInfo(Shelter shelter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shelter.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(shelter.direccion ?? "Sin dirección", style: const TextStyle(color: Colors.grey)),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Cercanía: ${_getDistance(shelter.lat, shelter.long)}", 
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("Ver Refugio", style: TextStyle(color: Colors.white)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
