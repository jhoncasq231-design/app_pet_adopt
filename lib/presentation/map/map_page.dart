import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/shelter.dart';

class MapPage extends StatefulWidget {
  final bool isPicker;

  const MapPage({super.key, this.isPicker = false});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Shelter> _sheltersFromDb = [];
  LatLng? _userLocation;
  LatLng? _pickedLocation;
  String? _pickedLocationName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSheltersAndLocation();
  }

  Future<void> _fetchSheltersAndLocation() async {
    try {
      // Solicitar permisos de ubicación primero
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente');
      }

      // Solo cargamos refugios si NO estamos eligiendo una ubicación nueva
      if (!widget.isPicker) {
        final response = await supabase
            .from('shelters')
            .select('id, nombre, direccion, lat, long');
        _sheltersFromDb = (response as List)
            .map((s) => Shelter.fromMap(s))
            .toList();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController.move(_userLocation!, 14.0);
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _getLocationName(LatLng location) async {
    try {
      print(
        '🔍 Haciendo reverse geocoding para: ${location.latitude}, ${location.longitude}',
      );
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      print('📍 Placemarks encontrados: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final locationName = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        if (mounted) {
          setState(() => _pickedLocationName = locationName);
        }
        print('✅ Ubicación determinada: $locationName');
      } else {
        print('⚠️ No se encontraron placemarks para estas coordenadas');
        setState(() => _pickedLocationName = 'Ubicación desconocida');
      }
    } catch (e) {
      print('❌ Error en reverse geocoding: $e');
      setState(() => _pickedLocationName = 'Ubicación desconocida');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isPicker
          ? AppBar(
              title: const Text("Selecciona ubicación"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            )
          : null,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-0.1806, -78.4678),
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                if (widget.isPicker) {
                  print('🖱️  UBICACIÓN SELECCIONADA EN MAPA:');
                  print('   Latitud: ${point.latitude}');
                  print('   Longitud: ${point.longitude}');
                  setState(() {
                    _pickedLocation = point;
                    _pickedLocationName = null;
                  });
                  _getLocationName(point);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.petadopt.app',
              ),
              MarkerLayer(
                markers: [
                  // Mi ubicación actual (punto azul)
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),

                  // Modo Picker: Marcador de selección (naranja)
                  if (widget.isPicker && _pickedLocation != null)
                    Marker(
                      point: _pickedLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.orange,
                        size: 50,
                      ),
                    ),

                  // Modo Visualización: Refugios de la DB
                  if (!widget.isPicker)
                    ..._sheltersFromDb
                        .map(
                          (shelter) => Marker(
                            point: LatLng(shelter.lat, shelter.long),
                            child: GestureDetector(
                              onTap: () => _showShelterInfo(shelter),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                ],
              ),
            ],
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),

          // Buscador (solo si no es picker)
          if (!widget.isPicker)
            Positioned(top: 50, left: 20, right: 20, child: _buildSearchBar()),

          // Botón de confirmar selección
          if (widget.isPicker && _pickedLocation != null)
            Positioned(
              bottom: 40,
              left: 50,
              right: 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_pickedLocationName != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 5),
                        ],
                      ),
                      child: Text(
                        _pickedLocationName!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pickedLocation != null
                          ? Colors.orange
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _pickedLocation == null
                        ? null
                        : () {
                            print('✅ CONFIRMANDO UBICACIÓN DESDE MAPA:');
                            print('   Lat: ${_pickedLocation!.latitude}');
                            print('   Lng: ${_pickedLocation!.longitude}');
                            print('   Nombre: $_pickedLocationName');
                            Navigator.pop(context, {
                              'lat': _pickedLocation!.latitude,
                              'lng': _pickedLocation!.longitude,
                              'locationName':
                                  _pickedLocationName ??
                                  'Ubicación desconocida',
                            });
                          },
                    child: const Text(
                      "Confirmar Ubicación",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shelter.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              shelter.direccion ?? "Sin dirección",
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cercanía: ${_getDistance(shelter.lat, shelter.long)}",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    "Ver Refugio",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDistance(double shelterLat, double shelterLng) {
    if (_userLocation == null) return "Calculando...";

    final distance = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      shelterLat,
      shelterLng,
    );

    final distanceInKm = distance / 1000;
    return "${distanceInKm.toStringAsFixed(2)} km";
  }
}
