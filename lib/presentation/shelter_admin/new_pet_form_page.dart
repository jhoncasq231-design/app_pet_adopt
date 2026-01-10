import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/colors.dart';
import '../../data/services/pet_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/pet_model.dart';

class NewPetFormPage extends StatefulWidget {
  final PetModel? pet;

  const NewPetFormPage({super.key, this.pet});

  @override
  State<NewPetFormPage> createState() => _NewPetFormPageState();
}

class _NewPetFormPageState extends State<NewPetFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _healthNotesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final _petService = PetService();
  final _imagePicker = ImagePicker();

  String _selectedSpecies = 'Perro';
  String _selectedSex = 'No especificado';
  String _selectedSize = 'Mediano';
  int _mainPhotoIndex = -1;
  List<File> _photoFiles = [];
  final int _maxPhotos = 5;
  bool _isLoading = false;

  // Estados de salud
  bool _isVaccinated = false;
  bool _isDewormed = false;
  bool _isSterilized = false;
  bool _hasMicrochip = false;
  bool _requiresSpecialCare = false;
  bool get isEditMode => widget.pet != null;

  @override
  void dispose() {
    _nameController.dispose();
    _raceController.dispose();
    _descriptionController.dispose();
    _healthNotesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.pet != null) {
      final pet = widget.pet!;
      _nameController.text = pet.name;
      _raceController.text = pet.raza ?? '';
      _descriptionController.text = pet.descripcion ?? '';
      _healthNotesController.text = pet.notasSalud ?? '';
      _ageController.text = pet.edadMeses?.toString() ?? '';

      _selectedSpecies = pet.especie;
      _selectedSex = pet.sex;
      _selectedSize = pet.size;

      _isVaccinated = pet.vacunado;
      _isDewormed = pet.desparasitado;
      _isSterilized = pet.esterilizado;
      _hasMicrochip = pet.microchip;
      _requiresSpecialCare = pet.cuidadosEspeciales;
    }
  }

  Future<void> _addPhoto() async {
    if (_photoFiles.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Máximo $_maxPhotos fotos permitidas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar diálogo para seleccionar fuente de foto
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar foto'),
          content: const Text('¿De dónde deseas obtener la foto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickPhoto(ImageSource.camera);
              },
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickPhoto(ImageSource.gallery);
              },
              child: const Text('Galería'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _photoFiles.add(File(pickedFile.path));
          if (_mainPhotoIndex == -1) {
            _mainPhotoIndex = 0;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoFiles.removeAt(index);
      if (_mainPhotoIndex == index) {
        _mainPhotoIndex = _photoFiles.isNotEmpty ? 0 : -1;
      } else if (_mainPhotoIndex > index) {
        _mainPhotoIndex--;
      }
    });
  }

  void _setMainPhoto(int index) {
    setState(() {
      _mainPhotoIndex = index;
    });
  }

  Future<void> _handlePublish() async {
    // Validaciones
    if (_photoFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor agrega al menos una foto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el nombre de la mascota'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor agrega una descripción'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener ID del refugio
      final shelterIdResult = await AuthService.getShelterIdForCurrentUser();
      if (shelterIdResult == null || shelterIdResult.isEmpty) {
        throw 'No se pudo obtener el ID del refugio. Asegúrate de estar registrado como refugio.';
      }

      // Parsear edad
      int? edadMeses;
      if (_ageController.text.isNotEmpty) {
        edadMeses = int.tryParse(_ageController.text);
      }

      // Crear o actualizar mascota
      final result = isEditMode
          ? await _petService.updatePet(
              petId: widget.pet!.id,
              nombre: _nameController.text.trim(),
              especie: _selectedSpecies,
              raza: _raceController.text.isNotEmpty
                  ? _raceController.text.trim()
                  : null,
              edadMeses: edadMeses,
              descripcion: _descriptionController.text.trim(),
              sexo: (_selectedSex == 'macho' || _selectedSex == 'hembra')
                  ? _selectedSex
                  : null,
              tamano: _selectedSize,
              vacunado: _isVaccinated,
              desparasitado: _isDewormed,
              esterilizado: _isSterilized,
              microchip: _hasMicrochip,
              cuidadosEspeciales: _requiresSpecialCare,
              notasSalud: _healthNotesController.text.isNotEmpty
                  ? _healthNotesController.text.trim()
                  : null,
            )
          : await _petService.createPet(
              nombre: _nameController.text.trim(),
              especie: _selectedSpecies,
              refugioId: shelterIdResult,
              raza: _raceController.text.isNotEmpty
                  ? _raceController.text.trim()
                  : null,
              edadMeses: edadMeses,
              descripcion: _descriptionController.text.trim(),
              sexo: (_selectedSex == 'macho' || _selectedSex == 'hembra')
                  ? _selectedSex
                  : null,
              tamano: _selectedSize,
              vacunado: _isVaccinated,
              desparasitado: _isDewormed,
              esterilizado: _isSterilized,
              microchip: _hasMicrochip,
              cuidadosEspeciales: _requiresSpecialCare,
              notasSalud: _healthNotesController.text.isNotEmpty
                  ? _healthNotesController.text.trim()
                  : null,
              imageFiles: _photoFiles,
              mainPhotoIndex: _mainPhotoIndex,
            );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? '¡Mascota actualizada exitosamente!'
                  : '¡Mascota publicada exitosamente!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error al publicar mascota'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER TEAL
            Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryTeal,
                    AppColors.primaryTeal.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditMode ? 'Editar Mascota' : 'Nueva Mascota',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEditMode
                            ? 'Actualiza la información de la mascota'
                            : 'Completa todos los campos requeridos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.assignment, color: Colors.white.withOpacity(0.6)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECCIÓN: FOTOS DE LA MASCOTA
                  Row(
                    children: [
                      const Icon(Icons.image_outlined, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Fotos de la Mascota',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mínimo 1 foto, máximo 5. La primera será la principal.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),

                  // GALERÍA DE FOTOS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Fotos ya agregadas
                        ..._photoFiles.asMap().entries.map((entry) {
                          int index = entry.key;
                          File photoFile = entry.value;
                          bool isMain = _mainPhotoIndex == index;
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isMain
                                          ? AppColors.primaryOrange
                                          : Colors.grey.shade300,
                                      width: isMain ? 3 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _setMainPhoto(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: FileImage(photoFile),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Badge PRINCIPAL
                                if (isMain)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            'PRINCIPAL',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // Botón eliminar
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      padding: const EdgeInsets.all(3),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Botón agregar foto
                        if (_photoFiles.length < _maxPhotos)
                          GestureDetector(
                            onTap: _addPhoto,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.teal,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color: AppColors.primaryTeal,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Agregar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primaryTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // INFO DE FOTOS
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_photoFiles.length}/$_maxPhotos fotos agregadas. Las fotos de buena calidad aumentan las adopciones.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // SECCIÓN: INFORMACIÓN BÁSICA
                  Row(
                    children: [
                      const Icon(Icons.info_outlined, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Información Básica',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // NOMBRE
                  Text(
                    '✨ NOMBRE DE LA MASCOTA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Luna, Rocky, Michi...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ESPECIE
                  Text(
                    '🐾 ESPECIE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSpecies,
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      items: ['Perro', 'Gato', 'Conejo', 'Otro'].map((species) {
                        return DropdownMenuItem(
                          value: species,
                          child: Text(species),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecies = value ?? 'Perro';
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // EDAD (MESES)
                  Text(
                    '📅 EDAD (en meses)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ej: 6, 12, 24...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // SEXO
                  Text(
                    '⚧️ SEXO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSex,
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      items: ['No especificado', 'Macho', 'Hembra'].map((sex) {
                        return DropdownMenuItem(value: sex, child: Text(sex));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSex = value ?? 'No especificado';
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // TAMAÑO
                  Text(
                    '📏 TAMAÑO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSize,
                      isExpanded: true,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      items: ['Pequeño', 'Mediano', 'Grande', 'Muy Grande'].map(
                        (size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(size),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSize = value ?? 'Mediano';
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // RAZA
                  Text(
                    '🔍 RAZA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _raceController,
                    decoration: InputDecoration(
                      hintText: 'Ej: Golden Retriever, Siamés...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // SECCIÓN: DESCRIPCIÓN
                  Row(
                    children: [
                      const Icon(Icons.edit_note, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // CUÉNTANOS SOBRE ESTA MASCOTA
                  Text(
                    '💬 CUÉNTANOS SOBRE ESTA MASCOTA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText:
                          'Describe su personalidad, historia, comportamiento con niños y otras mascotas, nivel de actividad, qué tipo de hogar sería ideal...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // SUGERENCIAS
                  Text(
                    'Sugerencias:',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSuggestionChip('+ Juguetón'),
                      _buildSuggestionChip('+ Tranquilo'),
                      _buildSuggestionChip('+ Cariñoso'),
                      _buildSuggestionChip('+ Ideal para niños'),
                      _buildSuggestionChip('+ Apto departamento'),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // SECCIÓN: ESTADO DE SALUD
                  Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety_outlined,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Estado de Salud',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // VACUNADO
                  _buildHealthCheckbox(
                    value: _isVaccinated,
                    onChanged: (value) {
                      setState(() {
                        _isVaccinated = value ?? false;
                      });
                    },
                    title: 'Vacunado/a',
                    subtitle: 'Tiene todas las vacunas al día',
                    isSelected: _isVaccinated,
                  ),
                  const SizedBox(height: 12),

                  // DESPARASITADO
                  _buildHealthCheckbox(
                    value: _isDewormed,
                    onChanged: (value) {
                      setState(() {
                        _isDewormed = value ?? false;
                      });
                    },
                    title: 'Desparasitado/a',
                    subtitle: 'Tratamiento antiparasitario completado',
                    isSelected: _isDewormed,
                  ),
                  const SizedBox(height: 12),

                  // ESTERILIZADO
                  _buildHealthCheckbox(
                    value: _isSterilized,
                    onChanged: (value) {
                      setState(() {
                        _isSterilized = value ?? false;
                      });
                    },
                    title: 'Esterilizado/a',
                    subtitle: 'Ha sido castrado/a o esterilizado/a',
                    isSelected: _isSterilized,
                  ),
                  const SizedBox(height: 12),

                  // MICROCHIP
                  _buildHealthCheckbox(
                    value: _hasMicrochip,
                    onChanged: (value) {
                      setState(() {
                        _hasMicrochip = value ?? false;
                      });
                    },
                    title: 'Microchip',
                    subtitle: 'Tiene microchip de identificación',
                    isSelected: _hasMicrochip,
                  ),
                  const SizedBox(height: 12),

                  // REQUIERE CUIDADOS ESPECIALES
                  _buildHealthCheckbox(
                    value: _requiresSpecialCare,
                    onChanged: (value) {
                      setState(() {
                        _requiresSpecialCare = value ?? false;
                      });
                    },
                    title: 'Requiere cuidados especiales',
                    subtitle: 'Necesita medicación o atención particular',
                    isSelected: _requiresSpecialCare,
                  ),
                  const SizedBox(height: 16),

                  // NOTAS ADICIONALES DE SALUD
                  Text(
                    '🩺 NOTAS ADICIONALES DE SALUD (OPCIONAL)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _healthNotesController,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText:
                          'Alergias, medicamentos, condiciones crónicas, historial médico relevante...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      counterStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // BOTÓN PUBLICAR
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        disabledBackgroundColor: Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handlePublish,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  isEditMode
                                      ? 'Actualizar Mascota'
                                      : 'Publicar Mascota',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCheckbox({
    required bool value,
    required Function(bool?) onChanged,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryTeal.withOpacity(0.05)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryTeal : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryTeal
                      : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryTeal
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () {
        // Agregar texto sugerido al campo de descripción
        String currentText = _descriptionController.text;
        String suggestion = label.replaceFirst('+ ', '');

        if (currentText.isEmpty) {
          _descriptionController.text = suggestion;
        } else {
          _descriptionController.text = '$currentText, $suggestion';
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryOrange),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.primaryOrange),
        ),
      ),
    );
  }
}
