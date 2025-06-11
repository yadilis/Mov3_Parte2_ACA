import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'VistaScreen.dart';
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
      return Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Notas'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Cerrar sesión', style: TextStyle(color: const Color.fromARGB(255, 10, 10, 10))),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Agregar Nota"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuardarScreen(
                      notasRef: notasRef,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: notasRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(child: Text('No hay notas'));
                }

                final Map<dynamic, dynamic> notasMap =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final List<MapEntry<dynamic, dynamic>> notasList = notasMap.entries.toList();

                return ListView.builder(
                  itemCount: notasList.length,
                  itemBuilder: (context, index) {
                    final idNota = notasList[index].key;
                    final nota = Map<String, dynamic>.from(notasList[index].value);

                    return ListTile(
                      title: Text(nota['titulo'] ?? ''),
                      subtitle:
                          Text('Precio: \$${(nota['precio'] ?? 0).toStringAsFixed(2)}'),
                      onTap: () {
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
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
                            child: Text('Editar', style: TextStyle(color: Colors.orange)),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () => eliminarNota(idNota),
                            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
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
