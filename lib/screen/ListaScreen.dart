import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'VistaScreen.dart';

class ListaScreen extends StatefulWidget {
  @override
  _ListaScreenState createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference notaRef;

  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (user != null) {
      notaRef = FirebaseDatabase.instance
          .ref()
          .child('notas')
          .child(user!.uid)
          .child('notaPrincipal');
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _mostrarFormulario([Map<String, dynamic>? nota]) {
    if (nota != null) {
      _tituloController.text = nota['titulo'] ?? '';
      _descripcionController.text = nota['descripcion'] ?? '';
      _precioController.text = (nota['precio'] ?? '').toString();
    } else {
      _tituloController.clear();
      _descripcionController.clear();
      _precioController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Guardar Gasto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Ingrese un título' : null,
                ),
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Ingrese una descripción'
                      : null,
                ),
                TextFormField(
                  controller: _precioController,
                  decoration: InputDecoration(labelText: 'Precio'),
                  keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Ingrese un precio';
                    if (double.tryParse(val) == null) {
                      return 'Ingrese un precio válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final notaData = {
                        'titulo': _tituloController.text.trim(),
                        'descripcion': _descripcionController.text.trim(),
                        'precio': double.parse(_precioController.text.trim()),
                      };
                      await notaRef.set(notaData);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Guardar'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _eliminarNota() async {
    await notaRef.remove();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nota'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Cerrar sesión', style: TextStyle(color: const Color.fromARGB(255, 19, 19, 19))),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _mostrarFormulario(),
              child: Text('Agregar Nota'),
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: notaRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(child: Text('No hay nota guardada'));
                }

                final nota = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);

                return ListTile(
                  title: Text(nota['titulo'] ?? ''),
                  subtitle: Text(
                      'Precio: \$${(nota['precio'] != null ? (nota['precio'] as num).toDouble().toStringAsFixed(2) : '0.00')}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VistaScreen(
                          notaId: 'notaPrincipal',
                          nota: nota,
                          notasRef: FirebaseDatabase.instance
                              .ref()
                              .child('notas')
                              .child(user!.uid),
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _mostrarFormulario(nota),
                        child: Text('Editar',
                            style: TextStyle(color: Colors.orange)),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: _eliminarNota,
                        child: Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
