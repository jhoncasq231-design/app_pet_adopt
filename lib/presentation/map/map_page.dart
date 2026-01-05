import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Refugios')),
      body: Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.map, size: 80),
        ),
      ),
    );
  }
}
