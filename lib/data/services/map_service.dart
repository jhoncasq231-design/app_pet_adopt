import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/shelter.dart';

class MapService {
  final SupabaseClient supabase = Supabase.instance.client;

Future<List<Shelter>> fetchShelters() async {
  final response = await supabase
      .from('shelters')
      .select('id, nombre, direccion, lat, long');

  final List<Shelter> shelters = [];

  for (final item in response as List) {
    try {
      if (item['lat'] != null && item['long'] != null) {
        shelters.add(Shelter.fromMap(item));
      }
    } catch (_) {
      // Ignorar refugios sin GPS
    }
  }

  return shelters;
}

  Future<List<LatLng>> getRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson';

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    final coords = data['routes'][0]['geometry']['coordinates'];

    return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }
}
