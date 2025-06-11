import 'package:app_notas/screen/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasenia = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _contrasenia.dispose();
    super.dispose();
  }

  Future<void> registroFire(String correo, String contrasenia) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correo,
        password: contrasenia,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = '';
      if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil.';
      } else if (e.code == 'email-already-in-use') {
        mensaje = 'El correo ya está registrado.';
      } else {
        mensaje = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Registro",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _correo,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _contrasenia,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => registroFire(_correo.text, _contrasenia.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E70EE),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Registrarse"),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                    );
                  },
                  child: const Text(
                    " Inicia sesión",
                    style: TextStyle(color: Color(0xFF9E70EE)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
