import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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
              // Obtener y verificar tokens almacenados
              String? accessToken = await _authService.getAccessToken();
              String? refreshToken = await _authService.getRefreshToken();

              print("Nombre: ${user.displayName}");
              print("Correo: ${user.email}");
              print("Access Token: $accessToken");
              print("Refresh Token: $refreshToken");

              // Mensaje de éxito
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Inicio de sesión exitoso")),
              );

              // Redirigir a la pantalla principal
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            } else {
              // Mensaje de error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error al iniciar sesión")),
              );
            }
          },
          child: const Text('Iniciar sesión con Google'),
        ),
      ),
    );
  }
}
