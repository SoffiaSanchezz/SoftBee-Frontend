import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/model.dart';

class ApiService {
  static const String _baseUrl = 'https://softbee-back-end.onrender.com/api';
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ==================== MONITOREO ENDPOINTS ====================

  static Future<Map<String, dynamic>> iniciarMonitoreoVoz() async {
    try {
      final response = await http
          .post(Uri.parse('$_baseUrl/monitoreo/iniciar'), headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al iniciar monitoreo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

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

  static Future<List<Map<String, dynamic>>> obtenerMonitoreos() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/monitoreos'), headers: _headers)
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

  // ==================== APIARIOS ENDPOINTS ====================

  static Future<List<Apiario>> obtenerApiarios() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/apiaries'), headers: _headers)
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

  // ==================== PREGUNTAS ENDPOINTS ====================

  static Future<List<Pregunta>> obtenerPreguntasApiario(int apiarioId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/apiaries/$apiarioId/questions'),
            headers: _headers,
          )
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

  static Future<String> crearPregunta(Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/questions'),
            headers: _headers,
            body: json.encode(data),
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

  // ==================== VOZ ENDPOINTS ====================

  static Future<void> hablarTexto(String texto) async {
    try {
      await http
          .post(
            Uri.parse('$_baseUrl/voz/hablar'),
            headers: _headers,
            body: json.encode({'texto': texto}),
          )
          .timeout(_timeout);
    } catch (e) {
      debugPrint('Error al hablar texto: $e');
    }
  }

  static Future<Map<String, dynamic>> escucharAudio(int duracion) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/voz/escuchar'),
            headers: _headers,
            body: json.encode({'duracion': duracion}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al escuchar audio: ${response.statusCode}');
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
