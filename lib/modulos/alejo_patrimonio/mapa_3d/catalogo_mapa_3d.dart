import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';

/// El KML fija las ubicaciones; el repositorio de la app aporta las fichas.
class PuntoMapa3D {
  const PuntoMapa3D({
    required this.punto,
    required this.numero,
    required this.origen,
  });

  final PuntoPatrimonial punto;
  final int numero;
  final String origen;

  String? get imagenLocal {
    // La vista rápida conserva una foto offline aunque la ficha remota use URL.
    final candidatas = [
      ...punto.urlsImagenes,
      for (final local in puntosAlejo)
        if (local.id == punto.id) ...local.urlsImagenes,
    ];
    for (final path in candidatas) {
      if (path.startsWith('assets/imagenes/puntos/') &&
          !path.split('/').any((parte) => parte == '..' || parte == '.')) {
        return path;
      }
    }
    return null;
  }

  Map<String, Object> toJson() => {
    'id': punto.id,
    'name': punto.nombre,
    'number': numero,
    'location': [punto.lng, punto.lat],
    'source': origen,
    'address': punto.direccion,
    'description': punto.descripcion,
    if (imagenLocal != null) 'image': 'imagenes/$numero.jpg',
  };
}

class CatalogoMapa3D {
  CatalogoMapa3D(this._ubicaciones);

  final List<Map<String, dynamic>> _ubicaciones;

  static Future<CatalogoMapa3D> cargar() async {
    final data = jsonDecode(
      await rootBundle.loadString('assets/mapa_3d/area-catalog.json'),
    );
    return CatalogoMapa3D(
      (data['points'] as List).cast<Map<String, dynamic>>(),
    );
  }

  List<PuntoMapa3D> reconciliar(List<PuntoPatrimonial> fichas) {
    // Los metadatos locales completan una respuesta remota parcial.
    final porId = {
      for (final p in puntosAlejo) p.id: p,
      for (final p in fichas) p.id: p,
    };
    final resultado = <PuntoMapa3D>[];
    for (final location in _ubicaciones) {
      final ficha = porId.remove(location['id']);
      if (ficha == null) continue;
      resultado.add(
        PuntoMapa3D(
          numero: location['number'] as int,
          origen: 'KML',
          punto: PuntoPatrimonial(
            id: ficha.id,
            nombre: ficha.nombre,
            direccion: ficha.direccion,
            descripcion: ficha.descripcion,
            urlsImagenes: ficha.urlsImagenes,
            urlAudio: ficha.urlAudio,
            fuentes: ficha.fuentes,
            procedenciaImagenes: ficha.procedenciaImagenes,
            revisionEditorial: ficha.revisionEditorial,
            lat: (location['lat'] as num).toDouble(),
            lng: (location['lng'] as num).toDouble(),
          ),
        ),
      );
    }
    // Casa Crossa II no pertenece al KML: su origen y coordenadas se conservan.
    final crossa = porId['r1-casa-alberto-crossa-2'];
    if (crossa != null) {
      resultado.add(
        PuntoMapa3D(punto: crossa, numero: 24, origen: 'Catálogo de la app'),
      );
    }
    return List.unmodifiable(resultado);
  }
}
