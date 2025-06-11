import 'package:app_notas/screen/ListaScreen.dart';
import 'package:app_notas/screen/RegisterScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _contrasenia = TextEditingController();

  @override
  void dispose() {
    _correo.dispose();
    _contrasenia.dispose();
    super.dispose();
  }

  Future<void> loginFire(String correo, String contrasenia, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: contrasenia,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ListaScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = '';
      if (e.code == 'user-not-found') {
        mensaje = 'No existe un usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        mensaje = 'Contraseña incorrecta.';
      } else {
        mensaje = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Iniciar Sesión",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                height: 45,
                child: ElevatedButton(
                  onPressed: () => loginFire(_correo.text, _contrasenia.text, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E70EE), 
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Ingresar"),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Registro()),
                  );
                },
                child: const Text(
                  "¿No tienes cuenta? Regístrate aquí",
                  style: TextStyle(color: Color(0xFF9E70EE)), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
