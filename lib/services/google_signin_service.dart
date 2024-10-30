// lib/services/google_signin_service.dart

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email',
    ],
  );

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;

        // Imprimir el objeto account completo
        print(account);

        // Obtener la foto de perfil usando la Google People API
        String? photoUrl = await getUserProfile(auth.accessToken!);

        // Obtiene los datos
        return {
          'id': account.id,
          'email': account.email,
          'name': account.displayName,
          'photoUrl': photoUrl,
          'token': auth.accessToken,
        };
      }
    } catch (error) {
      print("Error al autenticar: $error");
    }
    return null;
  }

  Future<String?> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse(
          'https://people.googleapis.com/v1/people/me?personFields=photos'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final photos = data['photos'];
      if (photos != null && photos.isNotEmpty) {
        return photos[0]['url'];
      }
    } else {
      print('Error al obtener el perfil: ${response.statusCode}');
    }
    return null;
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      print("Sesión cerrada correctamente.");
    } catch (error) {
      print("Error al cerrar sesión: $error");
    }
  }
}
