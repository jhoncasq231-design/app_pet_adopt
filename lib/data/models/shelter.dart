class Shelter {
  final String id;
  final String nombre;
  final String? direccion;
  final double lat;
  final double long;

  Shelter({
    required this.id,
    required this.nombre,
    this.direccion,
    required this.lat,
    required this.long,
  });

factory Shelter.fromMap(Map<String, dynamic> map) {
  if (map['lat'] == null || map['long'] == null) {
    throw Exception('Shelter sin coordenadas GPS');
  }

  return Shelter(
    id: map['id'],
    nombre: map['nombre'],
    direccion: map['direccion'],
    lat: (map['lat'] as num).toDouble(),
    long: (map['long'] as num).toDouble(),
  );
}
}