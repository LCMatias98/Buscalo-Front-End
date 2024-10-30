import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './Interfaces/login_screen.dart';
import './services/google_signin_service.dart';

void iniciarSesionGoogle() async {
  final GoogleSignInService googleSignInService = GoogleSignInService();
  final userData = await googleSignInService.signInWithGoogle();

  if (userData != null) {
    print('ID: ${userData['id']}');
    print('Email: ${userData['email']}');
    print('Nombre: ${userData['name']}');
    print('Foto URL: ${userData['photoUrl']}');
    print('Token: ${userData['token']}');
  }
}

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
