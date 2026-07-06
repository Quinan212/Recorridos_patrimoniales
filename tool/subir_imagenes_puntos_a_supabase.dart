import 'dart:io';

import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_SERVICE_KEY');

void main() async {
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    stderr.writeln('Falta SUPABASE_URL o SUPABASE_SERVICE_KEY.');
    exitCode = 64;
    return;
  }

  final cliente = SupabaseClient(supabaseUrl, supabaseKey);
  final filas = <Map<String, dynamic>>[];

  for (final punto in puntosAlejo) {
    for (var indice = 0; indice < punto.urlsImagenes.length; indice++) {
      final rutaAsset = punto.urlsImagenes[indice];
      if (!rutaAsset.startsWith('assets/imagenes/puntos/')) continue;

      final archivo = File(rutaAsset);
      if (!archivo.existsSync()) {
        stderr.writeln('Falta el archivo: $rutaAsset');
        continue;
      }

      final extension = archivo.path.split('.').last.toLowerCase();
      final rutaStorage = 'points/${punto.id}/${indice + 1}.$extension';

      stdout.writeln('Subiendo $rutaStorage');
      await cliente.storage
          .from('point-images')
          .upload(
            rutaStorage,
            archivo,
            fileOptions: const FileOptions(
              upsert: true,
              cacheControl: '31536000',
              contentType: 'image/jpeg',
            ),
          );

      filas.add({
        'point_id': punto.id,
        'storage_path': rutaStorage,
        'public_url': null,
        'sort_order': indice,
      });
    }
  }

  await cliente.from('point_images').delete().neq('point_id', '');

  if (filas.isNotEmpty) {
    await cliente.from('point_images').insert(filas);
  }

  await cliente.from('points').update({'image_urls': <String>[]}).neq('id', '');

  stdout.writeln('Se subieron ${filas.length} imagenes.');
}
