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
    titulo: 'Presentación en Fundación Magma',
    descripcion:
        'Primera presentación pública del proyecto Recorridos Patrimoniales '
        'en la Fundación Magma. Compartimos la génesis de la aplicación, '
        'el proceso de investigación detrás del catálogo de obras de Alejo '
        'Martínez y la visión de poner el patrimonio arquitectónico al '
        'alcance de todos.\n\n'
        'La recepción del público fue excelente, con preguntas y debates '
        'que enriquecieron el enfoque del proyecto. También presentamos '
        'material gráfico inédito: planos originales, fotografías históricas '
        'y comparativas del estado actual de las obras.',
    nombreEvento: 'Fundación Magma',
    fechaEvento: DateTime(2025, 12),
    urlsImagenes: ['assets/imagenes/publicaciones/fundacion-magma.jpg'],
    orden: 0,
  ),
  Publicacion(
    id: 'pub-presentacion-2',
    titulo: 'Actividad interinstitucional en el Profesorado de Artes Visuales',
    descripcion:
        'Segunda presentación del proyecto, esta vez en el Profesorado '
        'de Artes Visuales. Abordamos la relación entre arte, arquitectura '
        'y tecnología: cómo una aplicación móvil puede convertirse en una '
        'herramienta de divulgación y concientización sobre el valor del '
        'patrimonio moderno en nuestra ciudad.\n\n'
        'Se realizó un recorrido virtual por las 23 obras catalogadas, '
        'mostrando el sistema de geolocalización, las fichas técnicas '
        'y el material audiovisual asociado. Los asistentes pudieron '
        'interactuar con un prototipo en vivo. La charla concluyó con '
        'intercambios muy valiosos sobre la preservación del patrimonio '
        'arquitectónico local.',
    nombreEvento: 'Profesorado de Artes Visuales',
    fechaEvento: DateTime(2026, 3),
    urlsImagenes: ['assets/imagenes/publicaciones/charla-artes-visuales.png'],
    orden: 1,
  ),
  Publicacion(
    id: 'pub-presentacion-3',
    titulo: 'Feria de las Carreras del IPC',
    descripcion:
        'Tercera presentación en la Feria de las Carreras del Instituto '
        'de Profesorado Concordia (IPC). Mostramos el proyecto a '
        'estudiantes secundarios y docentes interesados en conocer '
        'carreras vinculadas al patrimonio, la arquitectura y la '
        'tecnología.\n\n'
        'Expusimos el marco teórico y metodológico del proyecto, '
        'incluyendo el proceso de relevamiento, catalogación y '
        'digitalización de las obras de Alejo Martínez. Se destacó '
        'el carácter interdisciplinario del trabajo: arquitectura, '
        'historia, tecnología y comunicación convergiendo en una '
        'herramienta práctica para la puesta en valor del patrimonio.\n\n'
        'La ponencia generó interés en replicar la experiencia en otras '
        'instituciones educativas de la región.',
    nombreEvento: 'Feria de las Carreras - IPC',
    fechaEvento: DateTime(2026, 6),
    urlsImagenes: ['assets/imagenes/publicaciones/feria-carreras-ipc.jpeg'],
    orden: 2,
  ),
];

// Alias para compatibilidad
final List<Publicacion> publicacionesAlejo = [...publicacionesSeed];
