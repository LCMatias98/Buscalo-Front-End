import 'package:flutter/material.dart';
import '../auth_service.dart'; // Importa el servicio de autenticación
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService =
      AuthService(); // Instancia del servicio de autenticación

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await _authService.signInWithGoogle();
            if (user != null) {
              // Redirigir a la pantalla principal
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            }
          },
          child: const Text('Iniciar sesión con Google'),
        ),
      ),
    );
  }
}
