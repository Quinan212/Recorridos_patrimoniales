import 'dart:io';

import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';

void main() {
  final salida = StringBuffer()
    ..writeln('insert into public.points (')
    ..writeln(
      '  id, name, address, description, lat, lng, audio_url, image_urls, sort_order, is_active',
    )
    ..writeln(') values');

  for (var i = 0; i < puntosAlejo.length; i++) {
    final punto = puntosAlejo[i];
    final coma = i == puntosAlejo.length - 1 ? '' : ',';
    salida.writeln(
      '  (${_sql(punto.id)}, ${_sql(punto.nombre)}, ${_sql(punto.direccion)}, '
      '${_sql(punto.descripcion)}, ${punto.lat}, ${punto.lng}, '
      '${_sqlNulo(punto.urlAudio)}, ${_arraySql(punto.urlsImagenes)}, $i, true)$coma',
    );
  }

  salida
    ..writeln('on conflict (id) do update set')
    ..writeln('  name = excluded.name,')
    ..writeln('  address = excluded.address,')
    ..writeln('  description = excluded.description,')
    ..writeln('  lat = excluded.lat,')
    ..writeln('  lng = excluded.lng,')
    ..writeln('  audio_url = excluded.audio_url,')
    ..writeln('  image_urls = excluded.image_urls,')
    ..writeln('  sort_order = excluded.sort_order,')
    ..writeln('  is_active = excluded.is_active,')
    ..writeln('  updated_at = now();');

  stdout.write(salida);
}

String _sqlNulo(String? valor) {
  if (valor == null || valor.isEmpty) return 'null';
  return _sql(valor);
}

String _sql(String valor) => "'${valor.replaceAll("'", "''")}'";

String _arraySql(List<String> valores) {
  if (valores.isEmpty) return 'array[]::text[]';
  return 'array[${valores.map(_sql).join(', ')}]::text[]';
}
