import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/enhanced_models.dart';

class EnhancedApiService {
  static const String _baseUrl = 'https://softbee-back-end.onrender.com/api';
  static const Duration _timeout = Duration(seconds: 30);
  static String? _authToken;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ==================== AUTH ====================
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // ==================== APIARIOS ====================
  static Future<List<Apiario>> obtenerApiarios({int? userId}) async {
    try {
      String url = '$_baseUrl/apiaries';
      if (userId != null) {
        url = '$_baseUrl/users/$userId/apiaries';
      }

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Apiario.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener apiarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<int> crearApiario(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/apiaries'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        return result['id'] ?? -1;
      } else {
        throw Exception('Error al crear apiario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Apiario?> obtenerApiario(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/apiaries/$id'), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return Apiario.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener apiario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==================== PREGUNTAS ====================
  static Future<List<Pregunta>> obtenerPreguntasApiario(
    int apiarioId, {
    bool soloActivas = true,
  }) async {
    try {
      String url = '$_baseUrl/apiaries/$apiarioId/questions';
      if (soloActivas) {
        url += '?active_only=true';
      }

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pregunta.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener preguntas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<String> crearPregunta(Pregunta pregunta) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/questions'),
            headers: _headers,
            body: json.encode(pregunta.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        return result['id'] ?? '';
      } else {
        throw Exception('Error al crear pregunta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> actualizarPregunta(
    String preguntaId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/questions/$preguntaId'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar pregunta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> eliminarPregunta(String preguntaId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/questions/$preguntaId'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar pregunta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> reordenarPreguntas(
    int apiarioId,
    List<String> orden,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/apiaries/$apiarioId/questions/reorder'),
            headers: _headers,
            body: json.encode({'order': orden}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Error al reordenar preguntas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==================== NOTIFICACIONES REINA ====================
  static Future<List<NotificacionReina>> obtenerNotificacionesReina({
    int? apiarioId,
    bool soloNoLeidas = false,
  }) async {
    try {
      String url = '$_baseUrl/queen-notifications';
      List<String> params = [];

      if (apiarioId != null) params.add('apiario_id=$apiarioId');
      if (soloNoLeidas) params.add('unread_only=true');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificacionReina.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al obtener notificaciones: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<int> crearNotificacionReina(
    NotificacionReina notificacion,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/queen-notifications'),
            headers: _headers,
            body: json.encode(notificacion.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        return result['id'] ?? -1;
      } else {
        throw Exception('Error al crear notificación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> marcarNotificacionComoLeida(int notificacionId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/queen-notifications/$notificacionId/read'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Error al marcar notificación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==================== MONITOREO ====================
  static Future<int> crearMonitoreo(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/monitoreos'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        return result['id'] ?? -1;
      } else {
        throw Exception('Error al crear monitoreo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerMonitoreos({
    int? apiarioId,
  }) async {
    try {
      String url = '$_baseUrl/monitoreos';
      if (apiarioId != null) {
        url = '$_baseUrl/apiaries/$apiarioId/monitoreos';
      }

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener monitoreos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==================== UTILIDADES ====================
  static Future<bool> verificarConexion() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'), headers: _headers)
          .timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
