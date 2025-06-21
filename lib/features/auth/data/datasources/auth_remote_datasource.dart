import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sotfbee/features/auth/data/models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'https://softbee-back-end.onrender.com/api';

  static Future<Map<String, dynamic>> login(
    String identifier,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'identifier': identifier.trim(),
              'password': password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseBody['token'];
        return {
          'success': true,
          'token': token,
          'user_id': responseBody['user_id'],
          'username': responseBody['username'],
          'email': responseBody['email'],
          'message': 'Inicio de sesión exitoso',
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Error en el inicio de sesión',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>?> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<UserProfile?> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
    List<Map<String, dynamic>> apiaries,
  ) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'nombre': name,
          'username': generateUsername(email),
          'email': normalizedEmail,
          'phone': phone,
          'password': password,
          'apiarios': apiaries,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'token': responseBody['token'],
          'user_id': responseBody['user_id'],
          'message': responseBody['message'] ?? 'Registro exitoso',
        };
      } else {
        return {
          'success': false,
          'message': responseBody['error'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static String generateUsername(String email) {
    return email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': normalizedEmail}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message']};
      } else {
        return {
          'success': false,
          'message': responseBody['detail'] ?? 'Error al enviar correo',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password/$token'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'new_password': newPassword}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseBody['message']};
      } else {
        return {
          'success': false,
          'message': responseBody['detail'] ?? 'Error al cambiar contraseña',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Error cambiando contraseña'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateProfilePicture(
    String token,
    int userId,
    String newImagePath,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId/profile_picture'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'profile_picture': newImagePath}),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': 'Error actualizando foto de perfil',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
