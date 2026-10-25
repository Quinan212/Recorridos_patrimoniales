import 'package:flutter/foundation.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/configuracion_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepositorioPatrimonio extends ChangeNotifier {
  RepositorioPatrimonio({
    Future<List<Map<String, dynamic>>> Function()? cargarFilas,
  }) : _cargarFilas = cargarFilas;

  final Future<List<Map<String, dynamic>>> Function()? _cargarFilas;
  List<PuntoPatrimonial> _puntos = puntosAlejo;
  bool _estaCargando = false;

  List<PuntoPatrimonial> get puntos => _puntos;
  bool get estaCargando => _estaCargando;

  Future<void> cargar() async {
    if (_cargarFilas == null && !ConfiguracionSupabase.estaConfigurado) {
      debugPrint(
        'Supabase no esta configurado. Ejecuta con SUPABASE_URL y '
        'SUPABASE_ANON_KEY en dart-defines para cargar puntos e imagenes remotas.',
      );
      return;
    }

    _estaCargando = true;
    notifyListeners();

    try {
      final filas = _cargarFilas != null
          ? await _cargarFilas()
          : await Supabase.instance.client
                .from('points')
                .select(
                  'id,name,address,description,lat,lng,audio_url,sort_order,image_urls,point_images(storage_path,public_url,sort_order)',
                )
                .order('sort_order');

      final puntosRemotos = filas
          .map<PuntoPatrimonial>(_puntoDesdeFilaSupabase)
          .where((punto) => punto.id.isNotEmpty && punto.nombre.isNotEmpty)
          .toList(growable: false);

      if (puntosRemotos.isNotEmpty) {
        _puntos = puntosRemotos;
      }
    } catch (error, stackTrace) {
      debugPrint('No se pudieron cargar los puntos desde Supabase: $error');
      debugPrintStack(stackTrace: stackTrace);
      _puntos = puntosAlejo;
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  PuntoPatrimonial _puntoDesdeFilaSupabase(Map<String, dynamic> row) {
    return PuntoPatrimonial.desdeJson(
      row,
      urlsImagenes: _urlsImagenesDesdeFila(row),
    );
  }

  List<String> _urlsImagenesDesdeFila(Map<String, dynamic> row) {
    final urlsDirectas = row['image_urls'];
    if (urlsDirectas is List && urlsDirectas.isNotEmpty) {
      return urlsDirectas.whereType<String>().toList(growable: false);
    }

    final imagenes = row['point_images'];
    if (imagenes is! List) return const [];

    final imagenesOrdenadas =
        imagenes.whereType<Map<String, dynamic>>().toList()..sort((a, b) {
          final ordenA = (a['sort_order'] as num?)?.toInt() ?? 0;
          final ordenB = (b['sort_order'] as num?)?.toInt() ?? 0;
          return ordenA.compareTo(ordenB);
        });

    return imagenesOrdenadas
        .map((imagen) {
          final urlPublica = imagen['public_url'] as String?;
          if (urlPublica != null && urlPublica.isNotEmpty) return urlPublica;

          final rutaStorage = imagen['storage_path'] as String?;
          if (rutaStorage == null || rutaStorage.isEmpty) return null;

          return Supabase.instance.client.storage
              .from('point-images')
              .getPublicUrl(rutaStorage);
        })
        .whereType<String>()
        .toList(growable: false);
  }
}
