import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../data/services/auth_service.dart';
import '../../core/colors.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfilePage({required this.profileData, super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _ubicacionController;
  bool _isSaving = false;
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.profileData['nombre'] ?? '',
    );
    _telefonoController = TextEditingController(
      text: widget.profileData['telefono'] ?? '',
    );
    _ubicacionController = TextEditingController(
      text: widget.profileData['ubicacion'] ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
                _getImageFromCamera();
              },
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getImageFromGallery();
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

  Future<void> _getImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al acceder a la cámara: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
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

  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      final userId = AuthService.getCurrentUserId();
      if (userId == null) {
        print('Error: No hay usuario autenticado');
        return null;
      }

      final fileName = 'profile_$userId.jpg';
      final path = 'profile_pictures/$fileName';

      print('Subiendo imagen a: $path');

      await Supabase.instance.client.storage
          .from('pet-images')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('pet-images')
          .getPublicUrl(path);

      print('URL pública generada: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error al subir foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = AuthService.getCurrentUserId();
      if (userId == null) {
        throw 'No hay usuario autenticado';
      }

      // Si hay una imagen seleccionada, subirla primero
      String? fotoPerfil;
      if (_selectedImage != null) {
        print('Seleccionada imagen, subiendo...');
        fotoPerfil = await _uploadProfileImage(_selectedImage!);
        if (fotoPerfil == null) {
          throw 'Error al subir la imagen';
        }
        print('Imagen subida correctamente: $fotoPerfil');
      }

      final supabase = Supabase.instance.client;
      final updateData = {
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
        'ubicacion': _ubicacionController.text.trim().isEmpty
            ? null
            : _ubicacionController.text.trim(),
      };

      // Agregar foto solo si fue cargada
      if (fotoPerfil != null) {
        updateData['foto_perfil'] = fotoPerfil;
        print('Foto perfil agregada al update: $fotoPerfil');
      }

      print('Actualizando perfil en Supabase...');
      await supabase.from('profiles').update(updateData).eq('id', userId);
      print('Perfil actualizado correctamente');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Error general: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto de Perfil
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryTeal,
                        width: 3,
                      ),
                      color: Colors.grey[200],
                    ),
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (widget.profileData['foto_perfil'] != null &&
                                  widget.profileData['foto_perfil']
                                      .toString()
                                      .isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    widget.profileData['foto_perfil'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryTeal,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cambiar Foto de Perfil',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // Campos de Texto
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo Nombre
                    const Text(
                      'Nombre *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        hintText: 'Ingresa tu nombre',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primaryTeal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campo Teléfono
                    const Text(
                      'Teléfono',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Ej: +57 3001234567',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primaryTeal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campo Ubicación
                    const Text(
                      'Ubicación / Dirección',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ubicacionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ej: Calle 123 #45-67, Apartamento 2B',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primaryTeal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? 'Guardando...' : 'Guardar Cambios',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Botón Cancelar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text(
                          'Cancelar',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
