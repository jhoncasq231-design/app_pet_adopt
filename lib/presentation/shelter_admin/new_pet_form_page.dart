import 'package:flutter/material.dart';
import '../../core/colors.dart';

class NewPetFormPage extends StatefulWidget {
  const NewPetFormPage({super.key});

  @override
  State<NewPetFormPage> createState() => _NewPetFormPageState();
}

class _NewPetFormPageState extends State<NewPetFormPage> {
  String species = 'Perro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Mascota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fotos (1 a 5)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(
                child: Icon(Icons.add_a_photo, size: 40),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: 'Nombre',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                labelText: 'Raza',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: species,
              items: const [
                DropdownMenuItem(value: 'Perro', child: Text('Perro')),
                DropdownMenuItem(value: 'Gato', child: Text('Gato')),
              ],
              onChanged: (value) => setState(() => species = value!),
              decoration: InputDecoration(
                labelText: 'Especie',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Descripción rápida'),
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Juguetón')),
                Chip(label: Text('Tranquilo')),
                Chip(label: Text('Cariñoso')),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Salud'),
            CheckboxListTile(
              title: const Text('Vacunado'),
              value: true,
              onChanged: (_) {},
            ),
            CheckboxListTile(
              title: const Text('Desparasitado'),
              value: false,
              onChanged: (_) {},
            ),
            CheckboxListTile(
              title: const Text('Esterilizado'),
              value: true,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            padding: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () {},
          child: const Text('Guardar Mascota'),
        ),
      ),
    );
  }
}
