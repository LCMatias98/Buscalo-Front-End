import 'package:flutter/material.dart';
import '../auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

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
              // Imprime los datos de autenticación en la consola
              print("Nombre: ${user.displayName}");
              print("Correo: ${user.email}");
              print("Token: ${await user.getIdToken()}");

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
