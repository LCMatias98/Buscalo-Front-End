import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './services/auth_service.dart';
import './Interfaces/map_screen.dart'; // Importa tu archivo MapScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Buscalo",
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();

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
              onPressed: () async {
                var user = await _authService.signInWithGoogle();
                if (user != null) {
                  print("Usuario autenticado:");
                  print("Nombre: ${user.displayName}");
                  print("Correo: ${user.email}");
                  print("Token: ${await user.getIdToken()}");

                  // Redirigir al mapa después de autenticarse
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MapScreen()), // Usa el mapa con OSM
                  );
                } else {
                  print("Error en la autenticación con Google");
                }
              },
              child: const Text('Iniciar sesión con Google'),
            ),
          ],
        ),
      ),
    );
  }
}
