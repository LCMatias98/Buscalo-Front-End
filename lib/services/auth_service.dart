import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Iniciar sesión con Google y guardar los tokens
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Guardar tokens en SharedPreferences
        await saveTokens(googleAuth.accessToken!, googleAuth.idToken!);
        return userCredential.user;
      }
    } catch (error) {
      print(error); // Maneja el error según sea necesario
    }
    return null;
  }

  // Guardar tokens en SharedPreferences
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Obtener el access token almacenado
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Obtener el refresh token almacenado
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  // Eliminar tokens al cerrar sesión
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await clearTokens();
  }

  // Método para renovar el access token usando el refresh token
  Future<bool> refreshAccessToken() async {
    String? refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.31:8080/auth/refresh'), // Cambia a tu endpoint real
        body: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        // Asume que el nuevo access token está en el cuerpo de la respuesta
        String newAccessToken =
            response.body; // Ajusta según la respuesta del backend
        await saveTokens(newAccessToken, refreshToken);
        return true;
      }
    } catch (error) {
      print("Error al renovar el token: $error");
    }
    return false;
  }

  // Método para realizar una solicitud autenticada
  Future<http.Response> makeAuthenticatedRequest(String endpoint) async {
    String? accessToken = await getAccessToken();

    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    // Si el access token expiró, renueva y reintenta
    if (response.statusCode == 401) {
      bool refreshed = await refreshAccessToken();
      if (refreshed) {
        accessToken = await getAccessToken();
        return await http.get(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );
      } else {
        throw Exception("Error al renovar el token");
      }
    }

    return response;
  }
}
