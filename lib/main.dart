import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './Interfaces/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Buscalo",
      home:
          const Home(), // Cambia esto si quieres que la pantalla inicial sea diferente
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscalo"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Buscalo"),
            ElevatedButton(
              onPressed: () {
                // Redirige a la pantalla de inicio de sesión
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen()), // Eliminar `const`
                );
              },
              child: const Text('Iniciar sesión con Google'),
            ),
          ],
        ),
      ),
    );
  }
}
