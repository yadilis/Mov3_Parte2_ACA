import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VistaScreen extends StatelessWidget {
  final String notaId;
  final Map<dynamic, dynamic> nota;
  final DatabaseReference notasRef;

  VistaScreen({required this.notaId, required this.nota, required this.notasRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle del Gasto'),
      
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(nota['titulo'] ?? ''),
            SizedBox(height: 16),
            Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(nota['descripcion'] ?? ''),
            SizedBox(height: 16),
            Text('Precio:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('\$${(nota['precio'] ?? 0).toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
