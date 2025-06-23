// Modelos de datos
class Opcion {
  String valor;
  String? descripcion;

  Opcion({required this.valor, this.descripcion});

  Map<String, dynamic> toJson() {
    return {'valor': valor, 'descripcion': descripcion};
  }

  factory Opcion.fromJson(Map<String, dynamic> json) {
    return Opcion(valor: json['valor'], descripcion: json['descripcion']);
  }
}

class Pregunta {
  String id;
  String texto;
  bool seleccionada;
  List<Opcion>? opciones;
  String? tipoRespuesta; // "texto", "opciones", "numero", "rango"
  String? respuestaSeleccionada;
  bool obligatoria;
  int? min;
  int? max;
  String? dependeDe;

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
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id'],
      texto: json['pregunta'] ?? json['texto'],
      seleccionada: json['seleccionada'] ?? false,
      tipoRespuesta: json['tipo'] ?? json['tipoRespuesta'],
      obligatoria: json['obligatoria'] ?? false,
      opciones: json['opciones'] != null
          ? (json['opciones'] as List)
                .map((o) => o is String ? Opcion(valor: o) : Opcion.fromJson(o))
                .toList()
          : null,
      min: json['min'],
      max: json['max'],
      dependeDe: json['depende_de'] ?? json['dependeDe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregunta': texto,
      'tipo': tipoRespuesta,
      'obligatoria': obligatoria,
      'opciones': opciones?.map((o) => o.toJson()).toList(),
      'min': min,
      'max': max,
      'depende_de': dependeDe,
      'seleccionada': seleccionada,
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
    );
  }
}

class Apiario {
  final int id;
  final String nombre;
  final String ubicacion;

  Apiario({required this.id, required this.nombre, required this.ubicacion});

  factory Apiario.fromJson(Map<String, dynamic> json) {
    return Apiario(
      id: json['id'],
      nombre: json['nombre'],
      ubicacion: json['ubicacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'ubicacion': ubicacion};
  }
}

class Colmena {
  final int id;
  final int numeroColmena;
  final int idApiario;

  Colmena({
    required this.id,
    required this.numeroColmena,
    required this.idApiario,
  });

  factory Colmena.fromJson(Map<String, dynamic> json) {
    return Colmena(
      id: json['id'],
      numeroColmena: json['numero_colmena'],
      idApiario: json['id_apiario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'numero_colmena': numeroColmena, 'id_apiario': idApiario};
  }
}

class MonitoreoRespuesta {
  final String preguntaId;
  final String preguntaTexto;
  final dynamic respuesta;

  MonitoreoRespuesta({
    required this.preguntaId,
    required this.preguntaTexto,
    required this.respuesta,
  });

  Map<String, dynamic> toJson() {
    return {
      'pregunta_id': preguntaId,
      'pregunta_texto': preguntaTexto,
      'respuesta': respuesta,
    };
  }

  factory MonitoreoRespuesta.fromJson(Map<String, dynamic> json) {
    return MonitoreoRespuesta(
      preguntaId: json['pregunta_id'],
      preguntaTexto: json['pregunta_texto'],
      respuesta: json['respuesta'],
    );
  }
}
