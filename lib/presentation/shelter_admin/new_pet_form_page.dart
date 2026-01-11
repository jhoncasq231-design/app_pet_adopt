// ignore_for_file: use_build_context_synchronously
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
  final _nameController = TextEditingController();
  final _raceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _healthNotesController = TextEditingController();
  final _ageController = TextEditingController();

  final _petService = PetService();
  final _imagePicker = ImagePicker();

  bool get isEditMode => widget.pet != null;

  String _selectedSpecies = 'Perro';
  String _selectedSex = 'No especificado';
  String _selectedSize = 'Mediano';

  bool _isVaccinated = false;
  bool _isDewormed = false;
  bool _isSterilized = false;
  bool _hasMicrochip = false;
  bool _requiresSpecialCare = false;

  bool _isLoading = false;

  List<File> _photoFiles = [];
  int _mainPhotoIndex = -1;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final pet = widget.pet!;
      _nameController.text = pet.name;
      _raceController.text = pet.raza ?? '';
      _descriptionController.text = pet.descripcion ?? '';
      _healthNotesController.text = pet.notasSalud ?? '';
      _ageController.text = pet.edadMeses?.toString() ?? '';

      _selectedSpecies = pet.especie;
      _selectedSex = _capitalize(pet.sex);
      _selectedSize = pet.size;

      _isVaccinated = pet.vacunado;
      _isDewormed = pet.desparasitado;
      _isSterilized = pet.esterilizado;
      _hasMicrochip = pet.microchip;
      _requiresSpecialCare = pet.cuidadosEspeciales;
    }
  }

  String _capitalize(String? value) {
    if (value == null || value.isEmpty) return 'No especificado';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  Future<void> _handlePublish() async {
    if (!isEditMode && _photoFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Agrega al menos una foto')));
      return;
    }

    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campos obligatorios vacíos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final shelterId = await AuthService.getShelterIdForCurrentUser();
      if (shelterId == null) throw 'Refugio no encontrado';

      final edadMeses = int.tryParse(_ageController.text);

      final sexoValue = (_selectedSex == 'Macho' || _selectedSex == 'Hembra')
          ? _selectedSex.toLowerCase()
          : null;

      final result = isEditMode
          ? await _petService.updatePet(
              petId: widget.pet!.id,
              nombre: _nameController.text.trim(),
              especie: _selectedSpecies,
              raza: _raceController.text.trim().isEmpty
                  ? null
                  : _raceController.text.trim(),
              edadMeses: edadMeses,
              descripcion: _descriptionController.text.trim(),
              sexo: sexoValue,
              tamano: _selectedSize,
              vacunado: _isVaccinated,
              desparasitado: _isDewormed,
              esterilizado: _isSterilized,
              microchip: _hasMicrochip,
              cuidadosEspeciales: _requiresSpecialCare,
              notasSalud: _healthNotesController.text.trim().isEmpty
                  ? null
                  : _healthNotesController.text.trim(),
            )
          : await _petService.createPet(
              nombre: _nameController.text.trim(),
              especie: _selectedSpecies,
              refugioId: shelterId,
              raza: _raceController.text.trim().isEmpty
                  ? null
                  : _raceController.text.trim(),
              edadMeses: edadMeses,
              descripcion: _descriptionController.text.trim(),
              sexo: sexoValue,
              tamano: _selectedSize,
              vacunado: _isVaccinated,
              desparasitado: _isDewormed,
              esterilizado: _isSterilized,
              microchip: _hasMicrochip,
              cuidadosEspeciales: _requiresSpecialCare,
              notasSalud: _healthNotesController.text.trim().isEmpty
                  ? null
                  : _healthNotesController.text.trim(),
              imageFiles: _photoFiles,
              mainPhotoIndex: _mainPhotoIndex,
            );

      if (result['success'] == true) {
        Navigator.pop(context, true);
      } else {
        throw result['message'];
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Editar Mascota' : 'Nueva Mascota'),
        backgroundColor: AppColors.primaryTeal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTOS
            const Text(
              'Fotos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._photoFiles.asMap().entries.map((entry) {
                    int index = entry.key;
                    File file = entry.value;
                    bool isMainPhoto = index == _mainPhotoIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _mainPhotoIndex = isMainPhoto ? -1 : index;
                        });
                      },
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isMainPhoto
                                    ? AppColors.primaryTeal
                                    : Colors.grey,
                                width: isMainPhoto ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(file, fit: BoxFit.cover),
                            ),
                          ),
                          if (isMainPhoto)
                            Positioned(
                              top: 4,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTeal,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Principal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _photoFiles.removeAt(index);
                                  if (_mainPhotoIndex == index) {
                                    _mainPhotoIndex = -1;
                                  } else if (_mainPhotoIndex > index) {
                                    _mainPhotoIndex--;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: _addPhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // NOMBRE
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la mascota',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ESPECIE
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: InputDecoration(
                labelText: 'Especie',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Perro', child: Text('Perro')),
                DropdownMenuItem(value: 'Gato', child: Text('Gato')),
                DropdownMenuItem(value: 'Conejo', child: Text('Conejo')),
                DropdownMenuItem(value: 'Ave', child: Text('Ave')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: (value) {
                setState(() => _selectedSpecies = value ?? 'Perro');
              },
            ),
            const SizedBox(height: 16),

            // RAZA
            TextField(
              controller: _raceController,
              decoration: InputDecoration(
                labelText: 'Raza (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // EDAD
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Edad (meses)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // SEXO
            DropdownButtonFormField<String>(
              value: _selectedSex,
              decoration: InputDecoration(
                labelText: 'Sexo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'No especificado',
                  child: Text('No especificado'),
                ),
                DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
              ],
              onChanged: (value) {
                setState(() => _selectedSex = value ?? 'No especificado');
              },
            ),
            const SizedBox(height: 16),

            // TAMAÑO
            DropdownButtonFormField<String>(
              value: _selectedSize,
              decoration: InputDecoration(
                labelText: 'Tamaño',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Pequeño', child: Text('Pequeño')),
                DropdownMenuItem(value: 'Mediano', child: Text('Mediano')),
                DropdownMenuItem(value: 'Grande', child: Text('Grande')),
              ],
              onChanged: (value) {
                setState(() => _selectedSize = value ?? 'Mediano');
              },
            ),
            const SizedBox(height: 16),

            // DESCRIPCIÓN
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // NOTAS DE SALUD
            TextField(
              controller: _healthNotesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas de salud (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SALUD
            const Text(
              'Información de Salud',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Vacunado/a'),
              value: _isVaccinated,
              onChanged: (value) {
                setState(() => _isVaccinated = value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('Desparasitado/a'),
              value: _isDewormed,
              onChanged: (value) {
                setState(() => _isDewormed = value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('Esterilizado/a'),
              value: _isSterilized,
              onChanged: (value) {
                setState(() => _isSterilized = value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('Con microchip'),
              value: _hasMicrochip,
              onChanged: (value) {
                setState(() => _hasMicrochip = value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('Requiere cuidados especiales'),
              value: _requiresSpecialCare,
              onChanged: (value) {
                setState(() => _requiresSpecialCare = value ?? false);
              },
            ),
            const SizedBox(height: 24),

            // BOTÓN PUBLICAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePublish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isEditMode ? 'Actualizar Mascota' : 'Publicar Mascota',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    if (_photoFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 fotos permitidas')),
      );
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al seleccionar foto: $e')));
    }
  }
}
