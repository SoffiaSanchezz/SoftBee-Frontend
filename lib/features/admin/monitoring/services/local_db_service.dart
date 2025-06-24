import 'dart:async';
import 'dart:convert';
import 'package:sotfbee/features/admin/monitoring/models/model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class LocalDBService {
  static Database? _database;
  static const String _databaseName = 'beehive_monitoring.db';
  static const int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        profile_picture TEXT,
        fecha_creacion TEXT,
        token TEXT
      )
    ''');

    // Tabla de apiarios
    await db.execute('''
      CREATE TABLE apiarios (
        id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        user_id INTEGER,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT,
        metadatos TEXT,
        sincronizado INTEGER DEFAULT 0
      )
    ''');

    // Tabla de colmenas
    await db.execute('''
      CREATE TABLE colmenas (
        id INTEGER PRIMARY KEY,
        numero_colmena INTEGER NOT NULL,
        id_apiario INTEGER NOT NULL,
        activa INTEGER DEFAULT 1,
        fecha_creacion TEXT,
        fecha_ultima_inspeccion TEXT,
        estado_reina TEXT,
        metadatos TEXT,
        sincronizado INTEGER DEFAULT 0,
        FOREIGN KEY (id_apiario) REFERENCES apiarios (id)
      )
    ''');

    // Tabla de preguntas
    await db.execute('''
      CREATE TABLE preguntas (
        id TEXT PRIMARY KEY,
        texto TEXT NOT NULL,
        tipo_respuesta TEXT DEFAULT 'texto',
        opciones_json TEXT,
        obligatoria INTEGER DEFAULT 0,
        min_valor INTEGER,
        max_valor INTEGER,
        depende_de TEXT,
        orden INTEGER DEFAULT 0,
        activa INTEGER DEFAULT 1,
        apiario_id INTEGER,
        seleccionada INTEGER DEFAULT 0,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT,
        sincronizado INTEGER DEFAULT 0,
        FOREIGN KEY (apiario_id) REFERENCES apiarios (id)
      )
    ''');

    // Tabla de monitoreos
    await db.execute('''
      CREATE TABLE monitoreos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_colmena INTEGER NOT NULL,
        id_apiario INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        sincronizado INTEGER DEFAULT 0,
        datos_adicionales TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_colmena) REFERENCES colmenas (id),
        FOREIGN KEY (id_apiario) REFERENCES apiarios (id)
      )
    ''');

    // Tabla de respuestas
    await db.execute('''
      CREATE TABLE respuestas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monitoreo_id INTEGER NOT NULL,
        pregunta_id TEXT NOT NULL,
        pregunta_texto TEXT NOT NULL,
        respuesta TEXT,
        tipo_respuesta TEXT,
        fecha_respuesta TEXT,
        FOREIGN KEY (monitoreo_id) REFERENCES monitoreos (id)
      )
    ''');

    // Tabla de notificaciones
    await db.execute('''
      CREATE TABLE notificaciones_reina (
        id INTEGER PRIMARY KEY,
        apiario_id INTEGER NOT NULL,
        colmena_id INTEGER,
        tipo TEXT NOT NULL,
        titulo TEXT NOT NULL,
        mensaje TEXT NOT NULL,
        prioridad TEXT DEFAULT 'media',
        leida INTEGER DEFAULT 0,
        fecha_creacion TEXT NOT NULL,
        fecha_vencimiento TEXT,
        metadatos TEXT,
        sincronizado INTEGER DEFAULT 0,
        FOREIGN KEY (apiario_id) REFERENCES apiarios (id),
        FOREIGN KEY (colmena_id) REFERENCES colmenas (id)
      )
    ''');

    // Insertar datos de ejemplo
    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar nuevas columnas si es necesario
      try {
        await db.execute('ALTER TABLE apiarios ADD COLUMN metadatos TEXT');
        await db.execute('ALTER TABLE colmenas ADD COLUMN metadatos TEXT');
        await db.execute(
          'ALTER TABLE preguntas ADD COLUMN sincronizado INTEGER DEFAULT 0',
        );
      } catch (e) {
        // Las columnas ya existen
      }
    }
  }

  Future<void> _insertSampleData(Database db) async {
    try {
      // Insertar apiarios de ejemplo
      await db.insert('apiarios', {
        'id': 1,
        'nombre': 'Apiario Norte',
        'ubicacion': 'Campo Norte - Sector A',
        'user_id': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'sincronizado': 0,
      });

      await db.insert('apiarios', {
        'id': 2,
        'nombre': 'Apiario Sur',
        'ubicacion': 'Campo Sur - Sector B',
        'user_id': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'sincronizado': 0,
      });

      // Insertar colmenas de ejemplo
      final colmenas = [
        {'numero_colmena': 1, 'id_apiario': 1, 'estado_reina': 'Saludable'},
        {'numero_colmena': 2, 'id_apiario': 1, 'estado_reina': 'Saludable'},
        {'numero_colmena': 3, 'id_apiario': 1, 'estado_reina': 'Revisar'},
        {'numero_colmena': 1, 'id_apiario': 2, 'estado_reina': 'Saludable'},
        {'numero_colmena': 2, 'id_apiario': 2, 'estado_reina': 'Saludable'},
      ];

      for (final colmena in colmenas) {
        await db.insert('colmenas', {
          ...colmena,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'sincronizado': 0,
        });
      }

      // Insertar preguntas de ejemplo
      final preguntasEjemplo = [
        {
          'id': 'p1',
          'texto': '¿Cómo está la actividad en las piqueras?',
          'tipo_respuesta': 'opciones',
          'opciones_json': jsonEncode([
            {'valor': 'Baja'},
            {'valor': 'Media'},
            {'valor': 'Alta'},
          ]),
          'obligatoria': 1,
          'orden': 1,
          'apiario_id': 1,
        },
        {
          'id': 'p2',
          'texto': '¿Cuántos cuadros de alimento observas?',
          'tipo_respuesta': 'numero',
          'min_valor': 0,
          'max_valor': 10,
          'obligatoria': 1,
          'orden': 2,
          'apiario_id': 1,
        },
        {
          'id': 'p3',
          'texto': '¿Cuál es el estado de la reina?',
          'tipo_respuesta': 'opciones',
          'opciones_json': jsonEncode([
            {'valor': 'Presente'},
            {'valor': 'Ausente'},
            {'valor': 'Celdas reales'},
          ]),
          'obligatoria': 1,
          'orden': 3,
          'apiario_id': 1,
        },
      ];

      for (final pregunta in preguntasEjemplo) {
        await db.insert('preguntas', {
          ...pregunta,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'sincronizado': 0,
        });
      }

      debugPrint('✅ Datos de ejemplo insertados correctamente');
    } catch (e) {
      debugPrint('❌ Error al insertar datos de ejemplo: $e');
    }
  }

  // ==================== USUARIOS ====================
  Future<void> saveUser(Usuario usuario, String token) async {
    final db = await database;
    await db.insert('usuarios', {
      ...usuario.toJson(),
      'token': token,
      'fecha_creacion': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Usuario?> getCurrentUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Usuario.fromJson(maps.first);
    }
    return null;
  }

  Future<String?> getStoredToken() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      columns: ['token'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first['token'];
    }
    return null;
  }

  Future<void> clearUserData() async {
    final db = await database;
    await db.delete('usuarios');
  }

  // ==================== APIARIOS ====================
  Future<List<Apiario>> getApiarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'apiarios',
      orderBy: 'nombre ASC',
    );

    return List.generate(maps.length, (i) {
      return Apiario.fromJson(maps[i]);
    });
  }

  Future<int> insertApiario(Apiario apiario) async {
    final db = await database;
    return await db.insert('apiarios', {
      ...apiario.toJson(),
      'fecha_creacion': DateTime.now().toIso8601String(),
      'sincronizado': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateApiario(Apiario apiario) async {
    final db = await database;
    await db.update(
      'apiarios',
      {
        ...apiario.toJson(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
        'sincronizado': 0,
      },
      where: 'id = ?',
      whereArgs: [apiario.id],
    );
  }

  Future<void> deleteApiario(int id) async {
    final db = await database;
    await db.delete('apiarios', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== COLMENAS ====================
  Future<List<Colmena>> getColmenasByApiario(int apiarioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'colmenas',
      where: 'id_apiario = ? AND activa = 1',
      whereArgs: [apiarioId],
      orderBy: 'numero_colmena ASC',
    );

    return List.generate(maps.length, (i) {
      return Colmena.fromJson(maps[i]);
    });
  }

  Future<int> insertColmena(Colmena colmena) async {
    final db = await database;
    return await db.insert('colmenas', {
      ...colmena.toJson(),
      'fecha_creacion': DateTime.now().toIso8601String(),
      'sincronizado': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ==================== PREGUNTAS ====================
  Future<List<Pregunta>> getPreguntasByApiario(
    int apiarioId, {
    bool soloActivas = true,
  }) async {
    final db = await database;

    String whereClause = 'apiario_id = ?';
    List<dynamic> whereArgs = [apiarioId];

    if (soloActivas) {
      whereClause += ' AND activa = 1';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'preguntas',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'orden ASC',
    );

    return maps.map((map) {
      List<Opcion>? opciones;
      if (map['opciones_json'] != null) {
        final opcionesJson = jsonDecode(map['opciones_json']) as List;
        opciones = opcionesJson.map((o) => Opcion.fromJson(o)).toList();
      }

      return Pregunta(
        id: map['id'],
        texto: map['texto'],
        seleccionada: map['seleccionada'] == 1,
        tipoRespuesta: map['tipo_respuesta'],
        opciones: opciones,
        obligatoria: map['obligatoria'] == 1,
        min: map['min_valor'],
        max: map['max_valor'],
        dependeDe: map['depende_de'],
        orden: map['orden'] ?? 0,
        activa: map['activa'] == 1,
        apiarioId: map['apiario_id'],
        fechaCreacion: map['fecha_creacion'] != null
            ? DateTime.tryParse(map['fecha_creacion'])
            : null,
        fechaActualizacion: map['fecha_actualizacion'] != null
            ? DateTime.tryParse(map['fecha_actualizacion'])
            : null,
      );
    }).toList();
  }

  Future<void> savePregunta(Pregunta pregunta) async {
    final db = await database;

    final data = {
      'id': pregunta.id,
      'texto': pregunta.texto,
      'tipo_respuesta': pregunta.tipoRespuesta,
      'opciones_json': pregunta.opciones != null
          ? jsonEncode(pregunta.opciones!.map((o) => o.toJson()).toList())
          : null,
      'obligatoria': pregunta.obligatoria ? 1 : 0,
      'min_valor': pregunta.min,
      'max_valor': pregunta.max,
      'depende_de': pregunta.dependeDe,
      'orden': pregunta.orden,
      'activa': pregunta.activa ? 1 : 0,
      'apiario_id': pregunta.apiarioId,
      'seleccionada': pregunta.seleccionada ? 1 : 0,
      'fecha_actualizacion': DateTime.now().toIso8601String(),
      'sincronizado': 0,
    };

    await db.insert(
      'preguntas',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deletePregunta(String id) async {
    final db = await database;
    await db.delete('preguntas', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MONITOREOS ====================
  Future<int> saveMonitoreo(Map<String, dynamic> data) async {
    final db = await database;

    final monitoreo = {
      'id_colmena': data['colmena'] ?? data['id_colmena'],
      'id_apiario': data['id_apiario'],
      'fecha': data['fecha'] ?? DateTime.now().toIso8601String(),
      'sincronizado': 0,
      'datos_adicionales': data['datos_adicionales'] != null
          ? jsonEncode(data['datos_adicionales'])
          : null,
    };

    try {
      final id = await db.insert('monitoreos', monitoreo);
      debugPrint('✅ Monitoreo guardado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('❌ Error al guardar monitoreo: $e');
      return -1;
    }
  }

  Future<void> saveRespuestas(
    int monitoreoId,
    List<MonitoreoRespuesta> respuestas,
  ) async {
    final db = await database;

    try {
      await db.transaction((txn) async {
        for (final respuesta in respuestas) {
          await txn.insert('respuestas', {
            'monitoreo_id': monitoreoId,
            'pregunta_id': respuesta.preguntaId,
            'pregunta_texto': respuesta.preguntaTexto,
            'respuesta': respuesta.respuesta.toString(),
            'tipo_respuesta': respuesta.tipoRespuesta,
            'fecha_respuesta':
                respuesta.fechaRespuesta?.toIso8601String() ??
                DateTime.now().toIso8601String(),
          });
        }
      });
      debugPrint(
        '✅ ${respuestas.length} respuestas guardadas para monitoreo $monitoreoId',
      );
    } catch (e) {
      debugPrint('❌ Error al guardar respuestas: $e');
      throw e;
    }
  }

  Future<List<Monitoreo>> getMonitoreos({
    int? apiarioId,
    int? colmenaId,
  }) async {
    final db = await database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (apiarioId != null) {
      whereClause += ' AND m.id_apiario = ?';
      whereArgs.add(apiarioId);
    }

    if (colmenaId != null) {
      whereClause += ' AND m.id_colmena = ?';
      whereArgs.add(colmenaId);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT m.*, a.nombre as apiario_nombre, c.numero_colmena
      FROM monitoreos m
      JOIN apiarios a ON m.id_apiario = a.id
      JOIN colmenas c ON m.id_colmena = c.id
      WHERE $whereClause
      ORDER BY m.fecha DESC
    ''', whereArgs);

    List<Monitoreo> monitoreos = [];

    for (final map in maps) {
      // Obtener respuestas para cada monitoreo
      final respuestas = await db.query(
        'respuestas',
        where: 'monitoreo_id = ?',
        whereArgs: [map['id']],
      );

      final respuestasList = respuestas
          .map((r) => MonitoreoRespuesta.fromJson(r))
          .toList();

      monitoreos.add(
        Monitoreo(
          id: map['id'],
          idColmena: map['id_colmena'],
          idApiario: map['id_apiario'],
          fecha: DateTime.parse(map['fecha']),
          respuestas: respuestasList,
          sincronizado: map['sincronizado'] == 1,
          datosAdicionales: map['datos_adicionales'] != null
              ? jsonDecode(map['datos_adicionales'])
              : null,
        ),
      );
    }

    return monitoreos;
  }

  Future<List<Map<String, dynamic>>> getMonitoreosPendientes() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'monitoreos',
      where: 'sincronizado = 0',
      orderBy: 'fecha DESC',
    );

    // Obtener respuestas para cada monitoreo
    for (final monitoreo in maps) {
      final respuestas = await db.query(
        'respuestas',
        where: 'monitoreo_id = ?',
        whereArgs: [monitoreo['id']],
      );
      monitoreo['respuestas'] = respuestas;
    }

    return maps;
  }

  Future<void> marcarMonitoreoComoSincronizado(int monitoreoId) async {
    final db = await database;
    await db.update(
      'monitoreos',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [monitoreoId],
    );
  }

  // ==================== NOTIFICACIONES ====================
  Future<List<NotificacionReina>> getNotificacionesReina({
    int? apiarioId,
    bool soloNoLeidas = false,
  }) async {
    final db = await database;

    String whereClause = '1=1';
    List<dynamic> whereArgs = [];

    if (apiarioId != null) {
      whereClause += ' AND apiario_id = ?';
      whereArgs.add(apiarioId);
    }

    if (soloNoLeidas) {
      whereClause += ' AND leida = 0';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'notificaciones_reina',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'fecha_creacion DESC',
    );

    return maps.map((map) => NotificacionReina.fromJson(map)).toList();
  }

  Future<int> saveNotificacionReina(NotificacionReina notificacion) async {
    final db = await database;
    return await db.insert('notificaciones_reina', {
      ...notificacion.toJson(),
      'sincronizado': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> marcarNotificacionComoLeida(int id) async {
    final db = await database;
    await db.update(
      'notificaciones_reina',
      {'leida': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== ESTADÍSTICAS ====================
  Future<Map<String, dynamic>> getEstadisticas() async {
    final db = await database;

    final totalApiarios =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM apiarios'),
        ) ??
        0;

    final totalColmenas =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM colmenas WHERE activa = 1'),
        ) ??
        0;

    final totalMonitoreos =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM monitoreos'),
        ) ??
        0;

    final monitoreosPendientes =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM monitoreos WHERE sincronizado = 0',
          ),
        ) ??
        0;

    final notificacionesNoLeidas =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM notificaciones_reina WHERE leida = 0',
          ),
        ) ??
        0;

    return {
      'total_apiarios': totalApiarios,
      'total_colmenas': totalColmenas,
      'total_monitoreos': totalMonitoreos,
      'monitoreos_pendientes': monitoreosPendientes,
      'notificaciones_no_leidas': notificacionesNoLeidas,
    };
  }

  // ==================== UTILIDADES ====================
  Future<void> limpiarDatosAntiguos({int diasAntiguedad = 30}) async {
    final db = await database;
    final fechaLimite = DateTime.now().subtract(Duration(days: diasAntiguedad));

    await db.delete(
      'monitoreos',
      where: 'fecha < ? AND sincronizado = 1',
      whereArgs: [fechaLimite.toIso8601String()],
    );

    await db.delete(
      'notificaciones_reina',
      where: 'fecha_creacion < ? AND leida = 1',
      whereArgs: [fechaLimite.toIso8601String()],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
