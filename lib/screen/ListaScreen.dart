import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'DetalleScreen.dart';
import 'GuardarScreen.dart';

class ListaScreen extends StatefulWidget {
  const ListaScreen({Key? key}) : super(key: key);

  @override
  _ListaScreenState createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late DatabaseReference notasRef;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      notasRef = FirebaseDatabase.instance.ref().child('notas').child(user!.uid);
    }
  }

  Future<void> eliminarNota(String idNota) async {
    await notasRef.child(idNota).remove();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Notas'),
      
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuardarScreen(notasRef: notasRef),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E70EE),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Agregar Nota"),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: notasRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No hay notas'));
                }

                final Map<dynamic, dynamic> notasMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final List<MapEntry<dynamic, dynamic>> notasList =
                    notasMap.entries.toList();

                return ListView.builder(
                  itemCount: notasList.length,
                  itemBuilder: (context, index) {
                    final idNota = notasList[index].key;
                    final nota = Map<String, dynamic>.from(notasList[index].value);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nota['titulo'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Precio: \$${(nota['precio'] ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VistaScreen(
                                          notaId: idNota,
                                          nota: nota,
                                          notasRef: notasRef,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9E70EE),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Text("Detalle"),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GuardarScreen(
                                          notaId: idNota,
                                          nota: nota,
                                          notasRef: notasRef,
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF9E70EE),
                                    side: const BorderSide(color: Color(0xFF9E70EE)),
                                  ),
                                  child: const Text("Editar"),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => eliminarNota(idNota),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text("Eliminar"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
