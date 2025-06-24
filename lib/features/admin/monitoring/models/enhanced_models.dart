// Enhanced data models with better integration
import 'package:sotfbee/features/admin/monitoring/models/model.dart';

class Opcion {
  String valor;
  String? descripcion;
  int? orden;

  Opcion({required this.valor, this.descripcion, this.orden});

  Map<String, dynamic> toJson() {
    return {'valor': valor, 'descripcion': descripcion, 'orden': orden};
  }

  factory Opcion.fromJson(Map<String, dynamic> json) {
    return Opcion(
      valor: json['valor'],
      descripcion: json['descripcion'],
      orden: json['orden'],
    );
  }
}

class Pregunta {
  String id;
  String texto;
  bool seleccionada;
  List<Opcion>? opciones;
  String? tipoRespuesta;
  String? respuestaSeleccionada;
  bool obligatoria;
  int? min;
  int? max;
  String? dependeDe;
  int orden;
  bool activa;
  int? apiarioId;

  Pregunta({
    required this.id,
    required this.texto,
    required this.seleccionada,
    this.tipoRespuesta = "texto",
    this.opciones,
    this.respuestaSeleccionada,
    this.obligatoria = false,
    this.min,
    this.max,
    this.dependeDe,
    this.orden = 0,
    this.activa = true,
    this.apiarioId,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id'] ?? json['question_id'],
      texto: json['pregunta'] ?? json['question_text'] ?? json['texto'],
      seleccionada: json['seleccionada'] ?? false,
      tipoRespuesta:
          json['tipo'] ?? json['question_type'] ?? json['tipoRespuesta'],
      obligatoria: json['obligatoria'] ?? json['is_required'] ?? false,
      opciones: json['opciones'] != null || json['options'] != null
          ? ((json['opciones'] ?? json['options']) as List?)
                ?.map(
                  (o) => o is String ? Opcion(valor: o) : Opcion.fromJson(o),
                )
                .toList()
          : null,
      min: json['min'] ?? json['min_value'],
      max: json['max'] ?? json['max_value'],
      dependeDe: json['depende_de'] ?? json['depends_on'] ?? json['dependeDe'],
      orden: json['orden'] ?? json['display_order'] ?? 0,
      activa: json['activa'] ?? json['is_active'] ?? true,
      apiarioId: json['apiario_id'] ?? json['apiary_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': texto,
      'question_type': tipoRespuesta,
      'is_required': obligatoria,
      'opciones': opciones?.map((o) => o.toJson()).toList(),
      'min_value': min,
      'max_value': max,
      'depends_on': dependeDe,
      'seleccionada': seleccionada,
      'display_order': orden,
      'is_active': activa,
      'apiary_id': apiarioId,
    };
  }

  Pregunta copyWith({
    String? id,
    String? texto,
    bool? seleccionada,
    List<Opcion>? opciones,
    String? tipoRespuesta,
    String? respuestaSeleccionada,
    bool? obligatoria,
    int? min,
    int? max,
    String? dependeDe,
    int? orden,
    bool? activa,
    int? apiarioId,
  }) {
    return Pregunta(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      seleccionada: seleccionada ?? this.seleccionada,
      opciones: opciones ?? this.opciones,
      tipoRespuesta: tipoRespuesta ?? this.tipoRespuesta,
      respuestaSeleccionada:
          respuestaSeleccionada ?? this.respuestaSeleccionada,
      obligatoria: obligatoria ?? this.obligatoria,
      min: min ?? this.min,
      max: max ?? this.max,
      dependeDe: dependeDe ?? this.dependeDe,
      orden: orden ?? this.orden,
      activa: activa ?? this.activa,
      apiarioId: apiarioId ?? this.apiarioId,
    );
  }
}

class Apiario {
  final int id;
  final String nombre;
  final String ubicacion;
  final int? userId;
  final DateTime? fechaCreacion;
  final List<Colmena>? colmenas;
  final List<Pregunta>? preguntas;

  Apiario({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    this.userId,
    this.fechaCreacion,
    this.colmenas,
    this.preguntas,
  });

  factory Apiario.fromJson(Map<String, dynamic> json) {
    return Apiario(
      id: json['id'],
      nombre: json['nombre'] ?? json['name'],
      ubicacion: json['ubicacion'] ?? json['location'],
      userId: json['user_id'],
      fechaCreacion: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      colmenas: json['colmenas'] != null
          ? (json['colmenas'] as List).map((c) => Colmena.fromJson(c)).toList()
          : null,
      preguntas: json['preguntas'] != null
          ? (json['preguntas'] as List)
                .map((p) => Pregunta.fromJson(p))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': nombre, 'location': ubicacion, 'user_id': userId};
  }
}

class NotificacionReina {
  final int id;
  final int apiarioId;
  final int? colmenaId;
  final String tipo; // 'alerta', 'recordatorio', 'cambio_estado'
  final String titulo;
  final String mensaje;
  final String prioridad; // 'baja', 'media', 'alta', 'critica'
  final bool leida;
  final DateTime fechaCreacion;
  final DateTime? fechaVencimiento;
  final Map<String, dynamic>? metadatos;

  NotificacionReina({
    required this.id,
    required this.apiarioId,
    this.colmenaId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.prioridad = 'media',
    this.leida = false,
    required this.fechaCreacion,
    this.fechaVencimiento,
    this.metadatos,
  });

  factory NotificacionReina.fromJson(Map<String, dynamic> json) {
    return NotificacionReina(
      id: json['id'],
      apiarioId: json['apiario_id'],
      colmenaId: json['colmena_id'],
      tipo: json['tipo'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      prioridad: json['prioridad'] ?? 'media',
      leida: json['leida'] ?? false,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaVencimiento: json['fecha_vencimiento'] != null
          ? DateTime.parse(json['fecha_vencimiento'])
          : null,
      metadatos: json['metadatos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apiario_id': apiarioId,
      'colmena_id': colmenaId,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'prioridad': prioridad,
      'leida': leida,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'metadatos': metadatos,
    };
  }
}
