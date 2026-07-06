class Publicacion {
  final String id;
  final String titulo;
  final String descripcion;
  final String nombreEvento;
  final DateTime? fechaEvento;
  final String? urlImagenPortada;
  final List<String> urlsImagenes;
  final List<String> subtitulosImagenes;
  final int orden;

  const Publicacion({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    this.nombreEvento = '',
    this.fechaEvento,
    this.urlImagenPortada,
    this.urlsImagenes = const [],
    this.subtitulosImagenes = const [],
    this.orden = 0,
  });

  factory Publicacion.desdeJson(
    Map<String, dynamic> json, {
    List<String> urlsImagenes = const [],
    List<String> subtitulosImagenes = const [],
  }) {
    DateTime? fecha;
    if (json['event_date'] is String) {
      fecha = DateTime.tryParse(json['event_date'] as String);
    }

    return Publicacion(
      id: json['id'] as String? ?? '',
      titulo: (json['title'] as String?) ?? '',
      descripcion: (json['description'] as String?) ?? '',
      nombreEvento: (json['event_name'] as String?) ?? '',
      fechaEvento: fecha,
      urlImagenPortada: (json['cover_image_url'] as String?)?.isNotEmpty == true
          ? json['cover_image_url'] as String
          : null,
      urlsImagenes: urlsImagenes,
      subtitulosImagenes: subtitulosImagenes,
      orden: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

// ======== PUBLICACIONES SEED ========
// Las 3 presentaciones ya realizadas + espacio para futuras.
// Cuando Supabase esté configurado, se cargan desde la nube.
final List<Publicacion> publicacionesSeed = [
  Publicacion(
    id: 'pub-presentacion-1',
    titulo: 'Presentacion en Fundacion Concordia',
    descripcion:
        'Primera presentacion publica del proyecto Recorridos Patrimoniales '
        'en la Fundacion Concordia. Compartimos la genesis de la aplicacion, '
        'el proceso de investigacion detras del catalogo de obras de Alejo '
        'Martinez y la vision de poner el patrimonio arquitectonico al '
        'alcance de todos.\n\n'
        'La recepcion del publico fue excelente, con preguntas y debates '
        'que enriquecieron el enfoque del proyecto. Tambien presentamos '
        'material grafico inedito: planos originales, fotografias historicas '
        'y comparativas del estado actual de las obras.',
    nombreEvento: 'Fundacion Concordia',
    fechaEvento: DateTime(2025, 12),
    orden: 0,
  ),
  Publicacion(
    id: 'pub-presentacion-2',
    titulo: 'Charla en el Profesorado de Artes Visuales',
    descripcion:
        'Segunda presentacion del proyecto, esta vez en el Profesorado '
        'de Artes Visuales. Abordamos la relacion entre arte, arquitectura '
        'y tecnologia: como una aplicacion movil puede convertirse en una '
        'herramienta de divulgacion y concientizacion sobre el valor del '
        'patrimonio moderno en nuestra ciudad.\n\n'
        'Se realizo un recorrido virtual por las 23 obras catalogadas, '
        'mostrando el sistema de geolocalizacion, las fichas tecnicas '
        'y el material audiovisual asociado. Los asistentes pudieron '
        'interactuar con un prototipo en vivo. La charla concluyo con '
        'intercambios muy valiosos sobre la preservacion del patrimonio '
        'arquitectonico local.',
    nombreEvento: 'Profesorado de Artes Visuales',
    fechaEvento: DateTime(2026, 3),
    orden: 1,
  ),
  Publicacion(
    id: 'pub-presentacion-3',
    titulo: 'Feria de las Carreras del IPC',
    descripcion:
        'Tercera presentacion en la Feria de las Carreras del Instituto '
        'de Profesorado Concordia (IPC). Mostramos el proyecto a '
        'estudiantes secundarios y docentes interesados en conocer '
        'carreras vinculadas al patrimonio, la arquitectura y la '
        'tecnologia.\n\n'
        'Expusimos el marco teorico y metodologico del proyecto, '
        'incluyendo el proceso de relevamiento, catalogacion y '
        'digitalizacion de las obras de Alejo Martinez. Se destaco '
        'el caracter interdisciplinario del trabajo: arquitectura, '
        'historia, tecnologia y comunicacion convergiendo en una '
        'herramienta practica para la puesta en valor del patrimonio.\n\n'
        'La ponencia genero interes en replicar la experiencia en otras '
        'instituciones educativas de la region.',
    nombreEvento: 'Feria de las Carreras - IPC',
    fechaEvento: DateTime(2026, 6),
    orden: 2,
  ),
];

// Alias para compatibilidad
final List<Publicacion> publicacionesAlejo = [
  ...publicacionesSeed,
];
