import 'dart:async';
import 'dart:convert';
import 'package:sotfbee/features/admin/monitoring/models/model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

class LocalDBService {
  static Database? _database;
  static const String _databaseName = 'beehive_monitoring.db';
  static const int _databaseVersion = 1;

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
    // Tabla de apiarios
    await db.execute('''
      CREATE TABLE apiarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        fecha_creacion TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabla de colmenas
    await db.execute('''
      CREATE TABLE colmenas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_colmena INTEGER NOT NULL,
        id_apiario INTEGER NOT NULL,
        activa INTEGER DEFAULT 1,
        fecha_creacion TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_apiario) REFERENCES apiarios (id)
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
        datos_json TEXT,
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
        fecha TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (monitoreo_id) REFERENCES monitoreos (id)
      )
    ''');

    // Tabla de preguntas personalizadas
    await db.execute('''
      CREATE TABLE preguntas_personalizadas (
        id TEXT PRIMARY KEY,
        texto TEXT NOT NULL,
        tipo_respuesta TEXT DEFAULT 'texto',
        opciones_json TEXT,
        obligatoria INTEGER DEFAULT 0,
        min_valor INTEGER,
        max_valor INTEGER,
        activa INTEGER DEFAULT 1,
        fecha_creacion TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insertar datos de ejemplo
    await _insertSampleData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Manejar actualizaciones de base de datos aquí
    if (oldVersion < 2) {
      // Ejemplo de migración
      // await db.execute('ALTER TABLE apiarios ADD COLUMN nueva_columna TEXT');
    }
  }

  Future<void> _insertSampleData(Database db) async {
    try {
      // Insertar apiarios de ejemplo
      await db.insert('apiarios', {
        'id': 1,
        'nombre': 'Apiario Norte',
        'ubicacion': 'Campo Norte - Sector A',
      });

      await db.insert('apiarios', {
        'id': 2,
        'nombre': 'Apiario Sur',
        'ubicacion': 'Campo Sur - Sector B',
      });

      await db.insert('apiarios', {
        'id': 3,
        'nombre': 'Apiario Central',
        'ubicacion': 'Campo Central - Sector C',
      });

      // Insertar colmenas de ejemplo
      final colmenas = [
        {'numero_colmena': 1, 'id_apiario': 1},
        {'numero_colmena': 2, 'id_apiario': 1},
        {'numero_colmena': 3, 'id_apiario': 1},
        {'numero_colmena': 4, 'id_apiario': 1},
        {'numero_colmena': 5, 'id_apiario': 1},
        {'numero_colmena': 1, 'id_apiario': 2},
        {'numero_colmena': 2, 'id_apiario': 2},
        {'numero_colmena': 3, 'id_apiario': 2},
        {'numero_colmena': 1, 'id_apiario': 3},
        {'numero_colmena': 2, 'id_apiario': 3},
      ];

      for (final colmena in colmenas) {
        await db.insert('colmenas', colmena);
      }

      debugPrint('✅ Datos de ejemplo insertados correctamente');
    } catch (e) {
      debugPrint('❌ Error al insertar datos de ejemplo: $e');
    }
  }

  // Métodos para Apiarios
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
    return await db.insert('apiarios', apiario.toJson());
  }

  // Métodos para Colmenas
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
    return await db.insert('colmenas', colmena.toJson());
  }

  // Métodos para Monitoreos
  Future<int> saveMonitoreo(Map<String, dynamic> data) async {
    final db = await database;

    final monitoreo = {
      'id_colmena': data['colmena'],
      'id_apiario': data['id_apiario'],
      'fecha': DateTime.now().toIso8601String(),
      'sincronizado': 0,
      'datos_json': jsonEncode(data),
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
            'fecha': DateTime.now().toIso8601String(),
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

  // Métodos para Preguntas Personalizadas
  Future<void> saveCustomQuestion(Pregunta pregunta) async {
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
    };

    await db.insert(
      'preguntas_personalizadas',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Pregunta>> getCustomQuestions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'preguntas_personalizadas',
      where: 'activa = 1',
      orderBy: 'fecha_creacion DESC',
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
        seleccionada: false,
        tipoRespuesta: map['tipo_respuesta'],
        opciones: opciones,
        obligatoria: map['obligatoria'] == 1,
        min: map['min_valor'],
        max: map['max_valor'],
      );
    }).toList();
  }

  // Métodos de estadísticas y reportes
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

    return {
      'total_apiarios': totalApiarios,
      'total_colmenas': totalColmenas,
      'total_monitoreos': totalMonitoreos,
      'monitoreos_pendientes': monitoreosPendientes,
    };
  }

  // Método para limpiar datos antiguos
  Future<void> limpiarDatosAntiguos({int diasAntiguedad = 30}) async {
    final db = await database;
    final fechaLimite = DateTime.now().subtract(Duration(days: diasAntiguedad));

    await db.delete(
      'monitoreos',
      where: 'fecha < ? AND sincronizado = 1',
      whereArgs: [fechaLimite.toIso8601String()],
    );
  }

  // Método para cerrar la base de datos
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
