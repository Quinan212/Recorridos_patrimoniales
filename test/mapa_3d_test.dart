import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/catalogo_mapa_3d.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/servidor_mapa_local.dart';

void main() {
  final data = jsonDecode(
    File('assets/mapa_3d/area-catalog.json').readAsStringSync(),
  );
  final ubicaciones = (data['points'] as List).cast<Map<String, dynamic>>();
  final catalogo = CatalogoMapa3D(ubicaciones);

  test('23 coordenadas exactas del KML y Crossa II con origen separado', () {
    final puntos = catalogo.reconciliar(puntosAlejo);
    expect(puntos, hasLength(24));
    expect(puntos.map((p) => p.punto.id).toSet(), hasLength(24));
    for (final source in ubicaciones) {
      final p = puntos.singleWhere((p) => p.punto.id == source['id']);
      expect(p.punto.lat, source['lat']);
      expect(p.punto.lng, source['lng']);
      expect(p.numero, source['number']);
      expect(p.origen, 'KML');
    }
    final casilla = puntos.singleWhere((p) => p.numero == 21);
    expect(casilla.punto.lat, -31.361992);
    expect(casilla.punto.lng, -58.06508);
    final crossa = puntos.singleWhere((p) => p.numero == 24);
    expect(crossa.punto.id, 'r1-casa-alberto-crossa-2');
    expect(crossa.origen, 'Catálogo de la app');
  });

  test(
    'las fichas remotas conservan audio, imágenes y fuentes sin mover el KML',
    () {
      final ficha = PuntoPatrimonial(
        id: puntosAlejo.first.id,
        nombre: 'Ficha actualizada',
        lat: 0,
        lng: 0,
        descripcion: 'Texto remoto',
        urlAudio: 'https://example.com/audio.mp3',
        urlsImagenes: ['imagen.jpg'],
      );
      final result = catalogo.reconciliar([ficha]);
      expect(result, hasLength(24));
      final p = result.first.punto;
      expect(p.nombre, 'Ficha actualizada');
      expect(p.descripcion, 'Texto remoto');
      expect(p.urlAudio, ficha.urlAudio);
      expect(p.urlsImagenes, ficha.urlsImagenes);
      expect(result.first.toJson()['description'], 'Texto remoto');
      expect(result.first.toJson()['image'], 'imagenes/1.jpg');
      expect(result.first.imagenLocal, startsWith('assets/imagenes/puntos/'));
      expect(p.lat, ubicaciones.first['lat']);
      expect(p.lat, isNot(0));
    },
  );

  test('todos los recursos del estilo y fuentes están incluidos', () {
    final assets =
        (jsonDecode(File('assets/mapa_3d/asset-list.json').readAsStringSync())
                as List)
            .cast<String>();
    final style = jsonDecode(
      File('assets/mapa_3d/style-native.json').readAsStringSync(),
    );
    for (final source in (style['sources'] as Map).values) {
      if (source['type'] == 'geojson') {
        expect(assets, contains(source['data']));
      } else {
        expect(source['type'], 'vector');
        expect(source['tiles'], ['contexto/{z}/{x}/{y}.pbf']);
        expect(source['maxzoom'], 15);
        expect(assets.where((a) => a.startsWith('contexto/')), hasLength(71));
      }
    }
    expect(assets, isNot(contains('cartografia/buildings.geojson')));
    expect(assets, isNot(contains('cartografia/shadows.geojson')));
    for (final asset in assets) {
      expect(File('assets/mapa_3d/$asset').existsSync(), isTrue, reason: asset);
    }
    expect(assets, contains('fonts/Open Sans Semibold/0-255.pbf'));
  });

  test(
    'HTTP local sirve solamente la lista permitida y libera el puerto',
    () async {
      final server = await ServidorMapaLocal.abrir(
        assets: {'index.html'},
        loader: (path) async {
          expect(path, 'assets/mapa_3d/index.html');
          return ByteData.sublistView(
            Uint8List.fromList(utf8.encode('<html>local</html>')),
          );
        },
      );
      final client = HttpClient();
      try {
        final response = await (await client.getUrl(server.inicio)).close();
        expect(response.statusCode, 200);
        expect(response.headers.contentType?.mimeType, 'text/html');
        expect(await utf8.decoder.bind(response).join(), '<html>local</html>');
        for (final uri in [
          server.inicio.resolve('pubspec.yaml'),
          server.inicio.resolve('../index.html'),
          server.inicio.replace(path: '/index.html'),
        ]) {
          final rejected = await (await client.getUrl(uri)).close();
          expect(rejected.statusCode, 404);
          await rejected.drain<void>();
        }
        final post = await (await client.postUrl(server.inicio)).close();
        expect(post.statusCode, 405);
        await post.drain<void>();
        expect(server.permite(Uri.parse('https://example.com')), isFalse);
        expect(server.permite(server.inicio), isTrue);
      } finally {
        client.close(force: true);
        await server.cerrar();
      }
    },
  );

  test('HTTP local resuelve los espacios de la ruta de las fuentes', () async {
    final server = await ServidorMapaLocal.abrir(
      assets: {'fonts/Open Sans Semibold/0-255.pbf'},
      loader: (path) async {
        expect(path, 'assets/mapa_3d/fonts/Open Sans Semibold/0-255.pbf');
        return ByteData.sublistView(Uint8List.fromList([1, 2, 3]));
      },
    );
    final client = HttpClient();
    try {
      final response = await (await client.getUrl(
        server.inicio.resolve('fonts/Open%20Sans%20Semibold/0-255.pbf'),
      )).close();
      expect(response.statusCode, 200);
      expect(
        await response.fold<List<int>>(
          [],
          (bytes, chunk) => bytes..addAll(chunk),
        ),
        [1, 2, 3],
      );
    } finally {
      client.close(force: true);
      await server.cerrar();
    }
  });

  test('la vista rápida sirve solo las fotos locales autorizadas', () async {
    final bytes = Uint8List.fromList([255, 216, 255, 217]);
    final server = await ServidorMapaLocal.abrir(
      assets: {},
      imagenes: {
        'imagenes/13.jpg': 'assets/imagenes/puntos/casa-cobelli/1.jpg',
        'imagenes/2.jpg': 'assets/imagenes/puntos/../privado.jpg',
        'imagenes/3.jpg': 'C:/privado.jpg',
      },
      loader: (path) async {
        expect(path, 'assets/imagenes/puntos/casa-cobelli/1.jpg');
        return ByteData.sublistView(bytes);
      },
    );
    final client = HttpClient();
    try {
      final photo = await (await client.getUrl(
        server.inicio.resolve('imagenes/13.jpg'),
      )).close();
      expect(photo.statusCode, 200);
      expect(photo.headers.contentType?.mimeType, 'image/jpeg');
      await photo.drain<void>();
      for (final path in [
        'imagenes/2.jpg',
        'imagenes/3.jpg',
        'imagenes/14.jpg',
        'assets/imagenes/puntos/casa-cobelli/1.jpg',
      ]) {
        final denied = await (await client.getUrl(
          server.inicio.resolve(path),
        )).close();
        expect(denied.statusCode, 404);
        await denied.drain<void>();
      }
    } finally {
      client.close(force: true);
      await server.cerrar();
    }
  });
}
