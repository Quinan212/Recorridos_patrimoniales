import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/datos/datos_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_punto_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_publicacion.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_mapa_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componente_reproductor_audio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_publicaciones.dart';

typedef AbrirSeccionBusqueda = void Function(int indice);

String normalizarTextoBusqueda(String valor) {
  return valor
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

int puntuarTextoBusqueda(String consultaCruda, String destinoCrudo) {
  final consulta = normalizarTextoBusqueda(consultaCruda);
  final destino = normalizarTextoBusqueda(destinoCrudo);
  if (consulta.isEmpty || destino.isEmpty) return 0;

  var score = 0;
  if (destino == consulta) score += 180;
  if (destino.startsWith(consulta)) score += 90;
  if (destino.contains(consulta)) score += 72;

  final consultaTokens = consulta.split(' ');
  final destinoTokens = destino.split(' ');
  var tokensCoincidentes = 0;

  for (final consultaToken in consultaTokens) {
    var mejor = 0;
    for (final destinoToken in destinoTokens) {
      if (destinoToken == consultaToken) {
        mejor = mejor < 38 ? 38 : mejor;
      } else if (destinoToken.startsWith(consultaToken)) {
        final valor = consultaToken.length <= 2 ? 24 : 31;
        mejor = mejor < valor ? valor : mejor;
      } else if (consultaToken.startsWith(destinoToken) &&
          destinoToken.length >= 3) {
        mejor = mejor < 20 ? 20 : mejor;
      } else if (consultaToken.length >= 4 && destinoToken.length >= 4) {
        final distancia = _distanciaLevenshtein(consultaToken, destinoToken);
        if (distancia == 1) {
          mejor = mejor < 22 ? 22 : mejor;
        } else if (distancia == 2 && consultaToken.length >= 6) {
          mejor = mejor < 13 ? 13 : mejor;
        }
      }
    }
    if (mejor > 0) tokensCoincidentes++;
    score += mejor;
  }

  if (consultaTokens.length > 1 &&
      tokensCoincidentes == consultaTokens.length) {
    score += 42;
  } else if (consultaTokens.length > 1) {
    score -= 18;
  }
  return score;
}

int _distanciaLevenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var anterior = List<int>.generate(b.length + 1, (indice) => indice);
  for (var i = 0; i < a.length; i++) {
    final actual = List<int>.filled(b.length + 1, 0);
    actual[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final insercion = actual[j] + 1;
      final eliminacion = anterior[j + 1] + 1;
      final sustitucion =
          anterior[j] + (a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1);
      actual[j + 1] = [
        insercion,
        eliminacion,
        sustitucion,
      ].reduce((menor, valor) => menor < valor ? menor : valor);
    }
    anterior = actual;
  }
  return anterior.last;
}

class BusquedaInteligenteDelegate extends SearchDelegate<void> {
  BusquedaInteligenteDelegate({required this.onOpenSection});

  final AbrirSeccionBusqueda onOpenSection;

  static const _acciones = <_AccionRapida>[
    _AccionRapida(
      id: 'recorrido-completo',
      titulo: 'Ver recorrido completo',
      subtitulo: 'Abrir el mapa con todas las obras patrimoniales.',
      icono: Icons.map_rounded,
      palabras:
          'mapa mapas recorrido recorridos ruta rutas obras puntos patrimonio patrimonial ubicacion ubicaciones donde llegar',
      tipo: _TipoAccion.mapa,
      destacada: true,
    ),
    _AccionRapida(
      id: 'obras-arquitectonicas',
      titulo: 'Explorar obras arquitectónicas',
      subtitulo: 'Recorrer las fichas de Alejo Martínez.',
      icono: Icons.account_balance_rounded,
      palabras:
          'obras obra arquitectura arquitectonicas alejo martinez casas viviendas edificios descubrir explorar recorrido',
      tipo: _TipoAccion.seccion,
      indiceSeccion: 1,
      destacada: true,
    ),
    _AccionRapida(
      id: 'puntos-con-audio',
      titulo: 'Puntos con audio',
      subtitulo: 'Encontrar las obras que tienen audioguía.',
      icono: Icons.headphones_rounded,
      palabras:
          'audio audios audioguia visita guiada escuchar escuchar obra relato sonido',
      tipo: _TipoAccion.consulta,
      consulta: 'audio',
      destacada: true,
    ),
    _AccionRapida(
      id: 'publicaciones',
      titulo: 'Publicaciones y eventos',
      subtitulo: 'Ver presentaciones, ferias y actividades del proyecto.',
      icono: Icons.article_rounded,
      palabras:
          'publicacion publicaciones eventos evento feria presentacion presentaciones charla proyecto noticias actividades',
      tipo: _TipoAccion.seccion,
      indiceSeccion: 3,
      destacada: true,
    ),
    _AccionRapida(
      id: 'informacion',
      titulo: 'Información y fuentes',
      subtitulo: 'Conocer el proyecto, su contexto y bibliografía.',
      icono: Icons.menu_book_rounded,
      palabras:
          'informacion info fuentes fuente bibliografia bibliografía contexto creditos créditos proyecto alejo historia patrimonio',
      tipo: _TipoAccion.seccion,
      indiceSeccion: 4,
      destacada: true,
    ),
    _AccionRapida(
      id: 'inicio',
      titulo: 'Volver al inicio',
      subtitulo: 'Regresar a la presentación del recorrido.',
      icono: Icons.home_rounded,
      palabras: 'inicio home portada presentacion recorrido',
      tipo: _TipoAccion.seccion,
      indiceSeccion: 0,
    ),
  ];

  @override
  String get searchFieldLabel => 'Buscar obras, publicaciones o acciones...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Limpiar búsqueda',
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Cerrar búsqueda',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    final puntos = context.watch<RepositorioPatrimonio>().puntos;
    final publicaciones = context
        .watch<RepositorioPublicaciones>()
        .publicaciones;
    final normalizada = normalizarTextoBusqueda(query);

    if (normalizada.isEmpty) {
      return _buildEmptyBody(context);
    }

    final acciones = _rankearAcciones(normalizada);
    final puntosEncontrados = _rankearPuntos(normalizada, puntos);
    final publicacionesEncontradas = _rankearPublicaciones(
      normalizada,
      publicaciones,
    );
    final total =
        acciones.length +
        puntosEncontrados.length +
        publicacionesEncontradas.length;

    if (total == 0) {
      return _buildNoResultsBody(context);
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          total == 1 ? '1 resultado útil' : '$total resultados útiles',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        if (acciones.isNotEmpty) ...[
          const SizedBox(height: 14),
          const _TituloResultados('Acciones rápidas'),
          const SizedBox(height: 8),
          ...acciones
              .take(5)
              .map(
                (resultado) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TarjetaAccion(
                    accion: resultado.item,
                    onTap: () => _ejecutarAccion(context, resultado.item),
                  ),
                ),
              ),
        ],
        if (puntosEncontrados.isNotEmpty) ...[
          const SizedBox(height: 14),
          const _TituloResultados('Obras y puntos patrimoniales'),
          const SizedBox(height: 8),
          ...puntosEncontrados
              .take(20)
              .map(
                (resultado) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TarjetaPuntoBusqueda(
                    punto: resultado.item,
                    onDetails: () => _abrirPunto(context, resultado.item),
                    onMap: () => _abrirMapa(context, resultado.item.id),
                    onAudio:
                        resultado.item.urlAudio == null ||
                            resultado.item.urlAudio!.isEmpty
                        ? null
                        : () => _reproducirAudio(context, resultado.item),
                  ),
                ),
              ),
        ],
        if (publicacionesEncontradas.isNotEmpty) ...[
          const SizedBox(height: 14),
          const _TituloResultados('Publicaciones y eventos'),
          const SizedBox(height: 8),
          ...publicacionesEncontradas
              .take(8)
              .map(
                (resultado) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TarjetaPublicacionBusqueda(
                    publicacion: resultado.item,
                    onTap: () => _abrirPublicacion(context, resultado.item),
                  ),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildEmptyBody(BuildContext context) {
    final destacadas = _acciones.where((accion) => accion.destacada).toList();
    const sugerencias = [
      'Casa Pendola Diaz',
      'Obras racionalistas',
      'Puntos con audio',
      'Obras en Mitre',
      'Casas de esquina',
      'Obras de 1929',
      'Mapa del recorrido',
      'Publicaciones del proyecto',
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      children: [
        const Text(
          'Accesos rápidos',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Buscá una obra, una dirección, un concepto o directamente lo que querés hacer.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final width = constraints.maxWidth >= 560
                ? (constraints.maxWidth - spacing * 2) / 3
                : (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: destacadas
                  .map(
                    (accion) => SizedBox(
                      width: width,
                      child: _TarjetaAccion(
                        accion: accion,
                        compacta: true,
                        onTap: () => _ejecutarAccion(context, accion),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Búsquedas sugeridas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sugerencias
              .map(
                (sugerencia) => ActionChip(
                  avatar: const Icon(Icons.north_west_rounded, size: 17),
                  label: Text(sugerencia),
                  onPressed: () => query = sugerencia,
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 18),
        Card(
          color: const Color(0xFFF7EDEE),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD32F2F)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La búsqueda entiende tildes, palabras incompletas, direcciones, años y errores frecuentes de escritura.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 52),
        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[500]),
        const SizedBox(height: 12),
        const Text(
          'No encontramos una coincidencia clara',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Probá con “mapa”, “casa”, “audio”, “racionalista”, “publicación” o una dirección.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () => _abrirMapa(context),
          icon: const Icon(Icons.map_rounded),
          label: const Text('Abrir mapa completo'),
        ),
      ],
    );
  }

  List<_ResultadoPuntuado<_AccionRapida>> _rankearAcciones(String consulta) {
    return _ordenar(
      _acciones.map((accion) {
        final score = puntuarTextoBusqueda(
          consulta,
          '${accion.titulo} ${accion.subtitulo} ${accion.palabras}',
        );
        return _ResultadoPuntuado(accion, score);
      }),
      consulta,
    );
  }

  List<_ResultadoPuntuado<PuntoPatrimonial>> _rankearPuntos(
    String consulta,
    List<PuntoPatrimonial> puntos,
  ) {
    return _ordenar(
      puntos.map((punto) {
        final aliases = <String>[
          'obra obras punto puntos patrimonio patrimonial arquitectura arquitectonico arquitectonica',
          if (punto.nombre.toLowerCase().contains('casa'))
            'vivienda hogar domicilio residencia',
          if (punto.descripcion.toLowerCase().contains('racionalista'))
            'racionalismo modernismo moderno modernidad',
          if (punto.descripcion.toLowerCase().contains('esquina'))
            'esquina ochava esquina urbana',
          if (punto.urlAudio != null && punto.urlAudio!.isNotEmpty)
            'audio audioguia visita guiada escuchar',
        ].join(' ');
        final texto = [
          punto.id,
          punto.nombre,
          punto.direccion,
          punto.descripcion,
          aliases,
        ].join(' ');
        final score =
            puntuarTextoBusqueda(consulta, texto) +
            puntuarTextoBusqueda(consulta, punto.nombre) * 2;
        return _ResultadoPuntuado(punto, score);
      }),
      consulta,
    );
  }

  List<_ResultadoPuntuado<Publicacion>> _rankearPublicaciones(
    String consulta,
    List<Publicacion> publicaciones,
  ) {
    return _ordenar(
      publicaciones.map((publicacion) {
        final fecha = publicacion.fechaEvento?.year.toString() ?? '';
        final texto = [
          publicacion.id,
          publicacion.titulo,
          publicacion.descripcion,
          publicacion.nombreEvento,
          fecha,
          'publicacion publicaciones evento eventos proyecto patrimonio arquitectura',
        ].join(' ');
        final score =
            puntuarTextoBusqueda(consulta, texto) +
            puntuarTextoBusqueda(consulta, publicacion.titulo) * 2;
        return _ResultadoPuntuado(publicacion, score);
      }),
      consulta,
    );
  }

  List<_ResultadoPuntuado<T>> _ordenar<T>(
    Iterable<_ResultadoPuntuado<T>> resultados,
    String consulta,
  ) {
    final filtrados = resultados
        .where((resultado) => resultado.score >= _umbral(consulta))
        .toList();
    filtrados.sort((a, b) => b.score.compareTo(a.score));
    return filtrados;
  }

  int _umbral(String consulta) {
    if (consulta.length <= 2) return 22;
    if (consulta.length <= 4) return 26;
    return 30;
  }

  void _ejecutarAccion(BuildContext context, _AccionRapida accion) {
    switch (accion.tipo) {
      case _TipoAccion.mapa:
        _abrirMapa(context);
        return;
      case _TipoAccion.seccion:
        final indice = accion.indiceSeccion;
        if (indice == null) return;
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onOpenSection(indice);
        });
        return;
      case _TipoAccion.consulta:
        query = accion.consulta ?? '';
        return;
    }
  }

  void _abrirPunto(BuildContext context, PuntoPatrimonial punto) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaDetallePuntoAlejo(punto: punto),
      ),
    );
  }

  void _abrirMapa(BuildContext context, [String? idPunto]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaMapaAlejo(idPuntoInicial: idPunto),
      ),
    );
  }

  void _reproducirAudio(BuildContext context, PuntoPatrimonial punto) {
    final url = punto.urlAudio;
    if (url == null || url.isEmpty) return;
    reproducirAudioGlobal(context, punto.nombre, url);
  }

  void _abrirPublicacion(BuildContext context, Publicacion publicacion) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaDetallePublicacion(publicacion: publicacion),
      ),
    );
  }
}

enum _TipoAccion { mapa, seccion, consulta }

class _AccionRapida {
  const _AccionRapida({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.palabras,
    required this.tipo,
    this.indiceSeccion,
    this.consulta,
    this.destacada = false,
  });

  final String id;
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final String palabras;
  final _TipoAccion tipo;
  final int? indiceSeccion;
  final String? consulta;
  final bool destacada;
}

class _ResultadoPuntuado<T> {
  const _ResultadoPuntuado(this.item, this.score);

  final T item;
  final int score;
}

class _TituloResultados extends StatelessWidget {
  const _TituloResultados(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}

class _TarjetaAccion extends StatelessWidget {
  const _TarjetaAccion({
    required this.accion,
    required this.onTap,
    this.compacta = false,
  });

  final _AccionRapida accion;
  final VoidCallback onTap;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${accion.titulo}. ${accion.subtitulo}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compacta ? 13 : 15),
            child: compacta
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(accion.icono, color: const Color(0xFFD32F2F)),
                      const SizedBox(height: 14),
                      Text(
                        accion.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7EDEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          accion.icono,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              accion.titulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              accion.subtitulo,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaPuntoBusqueda extends StatelessWidget {
  const _TarjetaPuntoBusqueda({
    required this.punto,
    required this.onDetails,
    required this.onMap,
    this.onAudio,
  });

  final PuntoPatrimonial punto;
  final VoidCallback onDetails;
  final VoidCallback onMap;
  final VoidCallback? onAudio;

  @override
  Widget build(BuildContext context) {
    final tieneAudio = punto.urlAudio != null && punto.urlAudio!.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EDEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        punto.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      if (punto.direccion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          punto.direccion,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (punto.descripcion.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                punto.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], height: 1.35),
              ),
            ],
            const SizedBox(height: 11),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Text('Ver ficha'),
                ),
                OutlinedButton.icon(
                  onPressed: onMap,
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('Mapa'),
                ),
                if (tieneAudio && onAudio != null)
                  FilledButton.icon(
                    onPressed: onAudio,
                    icon: const Icon(Icons.headphones_rounded),
                    label: const Text('Audio'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaPublicacionBusqueda extends StatelessWidget {
  const _TarjetaPublicacionBusqueda({
    required this.publicacion,
    required this.onTap,
  });

  final Publicacion publicacion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fecha = publicacion.fechaEvento == null
        ? null
        : DateFormat('d MMM yyyy', 'es_AR').format(publicacion.fechaEvento!);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.article_rounded, color: Color(0xFFD32F2F)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    publicacion.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (publicacion.nombreEvento.isNotEmpty || fecha != null) ...[
              const SizedBox(height: 7),
              Text(
                [
                  if (publicacion.nombreEvento.isNotEmpty)
                    publicacion.nombreEvento,
                  ?fecha,
                ].join(' · '),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
            if (publicacion.descripcion.isNotEmpty) ...[
              const SizedBox(height: 9),
              Text(
                publicacion.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], height: 1.35),
              ),
            ],
            const SizedBox(height: 11),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Abrir publicación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
