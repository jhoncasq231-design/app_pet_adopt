class PetModel {
  // IDs y datos básicos
  final String id;
  final String name; // Mantengo 'name' para compatibilidad con tu código
  final String breed;
  final String age;
  final String sex;
  final String size;
  final String distance;
  
  // Nuevos campos de Supabase
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
  
  // Información del refugio (opcional, para joins)
  final String? refugioNombre;
  final String? refugioTelefono;

  PetModel({
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

  // Factory para crear un PetModel vacío (para compatibilidad)
  factory PetModel.empty() {
    return PetModel(
      name: '',
      breed: '',
      age: '',
      sex: '',
      size: '',
      distance: '',
    );
  }

  // Factory para crear desde JSON de Supabase
  factory PetModel.fromJson(Map<String, dynamic> json) {
    // Calcular edad en formato texto desde edadMeses
    String ageText = '';
    if (json['edad_meses'] != null) {
      final meses = json['edad_meses'] as int;
      if (meses < 12) {
        ageText = '$meses ${meses == 1 ? 'mes' : 'meses'}';
      } else {
        final years = meses ~/ 12;
        final months = meses % 12;
        if (months == 0) {
          ageText = '$years ${years == 1 ? 'año' : 'años'}';
        } else {
          ageText = '$years ${years == 1 ? 'año' : 'años'} y $months ${months == 1 ? 'mes' : 'meses'}';
        }
      }
    }

    // Calcular tamaño basado en especie y raza (puedes personalizar esto)
    String sizeText = _calculateSize(json['especie'], json['raza']);

    return PetModel(
      id: json['id'] ?? '',
      name: json['nombre'] ?? '',
      breed: json['raza'] ?? 'Mestizo',
      age: ageText,
      sex: json['sexo'] ?? '',
      size: sizeText,
      distance: '0 km', // Se puede calcular después con la ubicación del usuario
      especie: json['especie'] ?? '',
      raza: json['raza'],
      edadMeses: json['edad_meses'],
      descripcion: json['descripcion'],
      fotos: json['fotos'] != null 
          ? List<String>.from(json['fotos']) 
          : [],
      fotoPrincipal: json['foto_principal'],
      refugioId: json['refugio_id'] ?? '',
      estado: json['estado'] ?? 'disponible',
      ubicacionLat: json['ubicacion_lat']?.toDouble(),
      ubicacionLong: json['ubicacion_long']?.toDouble(),
      vacunado: json['vacunado'] ?? false,
      desparasitado: json['desparasitado'] ?? false,
      esterilizado: json['esterilizado'] ?? false,
      microchip: json['microchip'] ?? false,
      cuidadosEspeciales: json['cuidados_especiales'] ?? false,
      notasSalud: json['notas_salud'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      refugioNombre: json['shelter']?['nombre'],
      refugioTelefono: json['shelter']?['telefono'],
    );
  }

  // Convertir a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'especie': especie,
      'raza': raza,
      'edad_meses': edadMeses,
      'sexo': sex,
      'descripcion': descripcion,
      'fotos': fotos,
      'foto_principal': fotoPrincipal,
      'refugio_id': refugioId,
      'estado': estado,
      'ubicacion_lat': ubicacionLat,
      'ubicacion_long': ubicacionLong,
      'vacunado': vacunado,
      'desparasitado': desparasitado,
      'esterilizado': esterilizado,
      'microchip': microchip,
      'cuidados_especiales': cuidadosEspeciales,
      'notas_salud': notasSalud,
    };
  }

  // Método para obtener la primera foto o un placeholder
  String get imagenPrincipal {
    if (fotoPrincipal != null && fotoPrincipal!.isNotEmpty) {
      return fotoPrincipal!;
    }
    if (fotos.isNotEmpty) {
      return fotos.first;
    }
    // Placeholder por defecto
    return 'https://via.placeholder.com/400x300?text=Sin+Foto';
  }

  // Getter para edad en formato de texto legible
  String get edadTexto {
    if (edadMeses == null) return 'Edad desconocida';
    if (edadMeses! < 12) {
      return '$edadMeses ${edadMeses == 1 ? 'mes' : 'meses'}';
    }
    final years = edadMeses! ~/ 12;
    final months = edadMeses! % 12;
    if (months == 0) {
      return '$years ${years == 1 ? 'año' : 'años'}';
    }
    return '$years ${years == 1 ? 'año' : 'años'} y $months ${months == 1 ? 'mes' : 'meses'}';
  }

  // Getter para mostrar estado de salud resumido
  String get saludResumen {
    List<String> estados = [];
    if (vacunado) estados.add('Vacunado');
    if (desparasitado) estados.add('Desparasitado');
    if (esterilizado) estados.add('Esterilizado');
    if (microchip) estados.add('Microchip');
    
    if (estados.isEmpty) return 'Sin información de salud';
    return estados.join(' • ');
  }

  // Método para verificar si está disponible
  bool get estaDisponible => estado == 'disponible';

  // Método para copiar con cambios
  PetModel copyWith({
    String? id,
    String? name,
    String? breed,
    String? age,
    String? sex,
    String? size,
    String? distance,
    String? especie,
    String? raza,
    int? edadMeses,
    String? descripcion,
    List<String>? fotos,
    String? fotoPrincipal,
    String? refugioId,
    String? estado,
    double? ubicacionLat,
    double? ubicacionLong,
    bool? vacunado,
    bool? desparasitado,
    bool? esterilizado,
    bool? microchip,
    bool? cuidadosEspeciales,
    String? notasSalud,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? refugioNombre,
    String? refugioTelefono,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      size: size ?? this.size,
      distance: distance ?? this.distance,
      especie: especie ?? this.especie,
      raza: raza ?? this.raza,
      edadMeses: edadMeses ?? this.edadMeses,
      descripcion: descripcion ?? this.descripcion,
      fotos: fotos ?? this.fotos,
      fotoPrincipal: fotoPrincipal ?? this.fotoPrincipal,
      refugioId: refugioId ?? this.refugioId,
      estado: estado ?? this.estado,
      ubicacionLat: ubicacionLat ?? this.ubicacionLat,
      ubicacionLong: ubicacionLong ?? this.ubicacionLong,
      vacunado: vacunado ?? this.vacunado,
      desparasitado: desparasitado ?? this.desparasitado,
      esterilizado: esterilizado ?? this.esterilizado,
      microchip: microchip ?? this.microchip,
      cuidadosEspeciales: cuidadosEspeciales ?? this.cuidadosEspeciales,
      notasSalud: notasSalud ?? this.notasSalud,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      refugioNombre: refugioNombre ?? this.refugioNombre,
      refugioTelefono: refugioTelefono ?? this.refugioTelefono,
    );
  }

  // Método auxiliar para calcular tamaño (puedes personalizarlo)
  static String _calculateSize(String? especie, String? raza) {
    if (especie == null) return 'Mediano';
    
    // Lógica simple para determinar tamaño
    if (especie.toLowerCase() == 'gato') return 'Pequeño';
    if (especie.toLowerCase() == 'conejo') return 'Pequeño';
    
    if (raza == null) return 'Mediano';
    
    // Razas grandes de perros
    final razasGrandes = [
      'labrador', 'golden', 'pastor', 'husky', 'rottweiler', 
      'doberman', 'gran danes', 'san bernardo'
    ];
    
    // Razas pequeñas
    final razasPequenas = [
      'chihuahua', 'pomerania', 'yorkshire', 'maltés', 'pug',
      'shih tzu', 'poodle toy', 'mini'
    ];
    
    final razaLower = raza.toLowerCase();
    
    if (razasGrandes.any((r) => razaLower.contains(r))) {
      return 'Grande';
    }
    
    if (razasPequenas.any((r) => razaLower.contains(r))) {
      return 'Pequeño';
    }
    
    return 'Mediano';
  }

  @override
  String toString() {
    return 'PetModel(id: $id, name: $name, especie: $especie, estado: $estado)';
  }
}