import 'package:flutter/foundation.dart';
import 'package:recorridos_patrimoniales/datos/datos_publicaciones.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/configuracion_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepositorioPublicaciones extends ChangeNotifier {
  List<Publicacion> _publicaciones = publicacionesAlejo;
  bool _estaCargando = false;

  List<Publicacion> get publicaciones => _publicaciones;
  bool get estaCargando => _estaCargando;

  Future<void> cargar() async {
    if (!ConfiguracionSupabase.estaConfigurado) {
      debugPrint(
        'Supabase no esta configurado. Usando datos locales de publicaciones.',
      );
      return;
    }

    _estaCargando = true;
    notifyListeners();

    try {
      final filas = await Supabase.instance.client
          .from('publications')
          .select(
            'id,title,description,event_name,event_date,cover_image_url,'
            'sort_order,publication_images(storage_path,public_url,caption,sort_order)',
          )
          .eq('is_published', true)
          .order('sort_order');

      final publicacionesRemotas = filas
          .map<Publicacion>(_publicacionDesdeFilaSupabase)
          .where((pub) => pub.id.isNotEmpty && pub.titulo.isNotEmpty)
          .toList(growable: false);

      if (publicacionesRemotas.isNotEmpty) {
        _publicaciones = publicacionesRemotas;
      }
    } catch (error, stackTrace) {
      debugPrint(
        'No se pudieron cargar las publicaciones desde Supabase: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      _publicaciones = publicacionesAlejo;
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  Publicacion _publicacionDesdeFilaSupabase(Map<String, dynamic> row) {
    final imagenes = row['publication_images'];
    List<String> urls = [];
    List<String> captions = [];

    if (imagenes is List) {
      final ordenadas =
          imagenes.whereType<Map<String, dynamic>>().toList()..sort((a, b) {
            final ordenA = (a['sort_order'] as num?)?.toInt() ?? 0;
            final ordenB = (b['sort_order'] as num?)?.toInt() ?? 0;
            return ordenA.compareTo(ordenB);
          });

      for (final img in ordenadas) {
        final urlPublica = img['public_url'] as String?;
        if (urlPublica != null && urlPublica.isNotEmpty) {
          urls.add(urlPublica);
        } else {
          final rutaStorage = img['storage_path'] as String?;
          if (rutaStorage != null && rutaStorage.isNotEmpty) {
            urls.add(
              Supabase.instance.client.storage
                  .from('publication-images')
                  .getPublicUrl(rutaStorage),
            );
          }
        }
        captions.add((img['caption'] as String?) ?? '');
      }
    }

    return Publicacion.desdeJson(
      row,
      urlsImagenes: urls,
      subtitulosImagenes: captions,
    );
  }
}
