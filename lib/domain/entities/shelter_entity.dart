class ShelterEntity {
  final String id;
  final String nombre;
  final String? direccion;
  final double lat;
  final double long;

  ShelterEntity({
    required this.id,
    required this.nombre,
    this.direccion,
    required this.lat,
    required this.long,
  });
}
