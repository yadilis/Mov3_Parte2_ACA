import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VistaScreen extends StatelessWidget {
  final String notaId;
  final Map<dynamic, dynamic> nota;
  final DatabaseReference notasRef;

  const VistaScreen({
    Key? key,
    required this.notaId,
    required this.nota,
    required this.notasRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Gasto'),
      ),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Título',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(nota['titulo'] ?? '', style: const TextStyle(fontSize: 16)),
                const Divider(height: 32),

                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(nota['descripcion'] ?? '', style: const TextStyle(fontSize: 16)),
                const Divider(height: 32),

                const Text(
                  'Precio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(nota['precio'] ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
