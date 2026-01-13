class PetEntity {
  // IDs y datos básicos
  final String id;
  final String name;
  final String breed;
  final String age;
  final String sex;
  final String size;
  final String distance;

  // Datos de Supabase
  final String especie;
  final String? raza;
  final int? edadMeses;
  final String? descripcion;
  final List<String> fotos;
  final String? fotoPrincipal;
  final String refugioId;
  final String estado;
  final double? ubicacionLat;
  final double? ubicacionLong;

  // Información de salud
  final bool vacunado;
  final bool desparasitado;
  final bool esterilizado;
  final bool microchip;
  final bool cuidadosEspeciales;
  final String? notasSalud;

  // Metadatos
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Información del refugio (opcional)
  final String? refugioNombre;
  final String? refugioTelefono;

  PetEntity({
    this.id = '',
    required this.name,
    required this.breed,
    required this.age,
    required this.sex,
    required this.size,
    required this.distance,
    this.especie = '',
    this.raza,
    this.edadMeses,
    this.descripcion,
    this.fotos = const [],
    this.fotoPrincipal,
    this.refugioId = '',
    this.estado = 'disponible',
    this.ubicacionLat,
    this.ubicacionLong,
    this.vacunado = false,
    this.desparasitado = false,
    this.esterilizado = false,
    this.microchip = false,
    this.cuidadosEspeciales = false,
    this.notasSalud,
    this.createdAt,
    this.updatedAt,
    this.refugioNombre,
    this.refugioTelefono,
  });
}
