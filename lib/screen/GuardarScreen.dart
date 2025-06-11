import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GuardarScreen extends StatefulWidget {
  final String? notaId;
  final Map<String, dynamic>? nota;
  final DatabaseReference? notasRef;

  const GuardarScreen({Key? key, this.notaId, this.nota, this.notasRef}) : super(key: key);

  @override
  _GuardarScreenState createState() => _GuardarScreenState();
}

class _GuardarScreenState extends State<GuardarScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.nota?['titulo'] ?? '');
    _descripcionController = TextEditingController(text: widget.nota?['descripcion'] ?? '');
    _precioController = TextEditingController(
      text: widget.nota != null ? widget.nota!['precio'].toString() : '',
    );
  }

  Future<void> guardarNota() async {
    if (!_formKey.currentState!.validate()) return;

    final titulo = _tituloController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final precio = double.parse(_precioController.text.trim());

    if (widget.notaId == null) {
      await widget.notasRef!.push().set({
        'titulo': titulo,
        'descripcion': descripcion,
        'precio': precio,
      });
    } else {
      await widget.notasRef!.child(widget.notaId!).update({
        'titulo': titulo,
        'descripcion': descripcion,
        'precio': precio,
      });
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.notaId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Nota' : 'Guardar Nota'),
       
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un precio';
                  if (double.tryParse(value) == null) return 'Ingrese un precio válido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: guardarNota,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E70EE),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEditing ? 'Guardar Cambios' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
