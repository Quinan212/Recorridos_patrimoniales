import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/almacen_teselas_mapa.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/servidor_mapa_local.dart';

void main() {
  late Directory directory;
  setUp(
    () async => directory = await Directory.systemTemp.createTemp('mapa-test-'),
  );
  tearDown(() async => directory.delete(recursive: true));

  AlmacenTeselasMapa almacen(
    Future<Uint8List?> Function(int, int, int) download, {
    int maxBytes = 24 * 1024 * 1024,
  }) => AlmacenTeselasMapa(
    assets: {'contexto/15/11103/19396.pbf'},
    directorio: directory,
    loader: (_) async => ByteData.sublistView(Uint8List.fromList([1, 2, 3, 4])),
    descargar: download,
    maxBytes: maxBytes,
  );

  test(
    'zona incluida funciona offline y los sectores nuevos persisten entre aperturas',
    () async {
      var requests = 0;
      final cache = almacen((z, x, y) async {
        requests++;
        return Uint8List.fromList([5, 6, 7, 8]);
      });
      expect(await cache.obtener('contexto/15/11103/19396.pbf'), [1, 2, 3, 4]);
      expect(requests, 0);
      expect(await cache.obtener('contexto/15/11108/19398.pbf'), [5, 6, 7, 8]);
      expect(requests, 1);
      cache.cerrar();
      final offline = almacen(
        (z, x, y) async => throw StateError('Sin Internet'),
      );
      expect(await offline.obtener('contexto/15/11108/19398.pbf'), [
        5,
        6,
        7,
        8,
      ]);
      expect(await offline.obtener('contexto/15/11109/19398.pbf'), isNull);
      offline.cerrar();
    },
  );

  test(
    'agrupa solicitudes iguales, limita descargas simultáneas y tamaño de cache',
    () async {
      var requests = 0, active = 0, peak = 0;
      final cache = almacen((z, x, y) async {
        requests++;
        active++;
        if (active > peak) peak = active;
        await Future<void>.delayed(const Duration(milliseconds: 40));
        active--;
        return Uint8List.fromList([x % 256, 2, 3, 4]);
      }, maxBytes: 8);
      final same = await Future.wait(
        List.generate(8, (_) => cache.obtener('contexto/15/11108/19398.pbf')),
      );
      expect(requests, 1);
      expect(same.every((bytes) => bytes![0] == 11108 % 256), true);
      await Future.wait(
        List.generate(
          6,
          (i) => cache.obtener('contexto/15/${11110 + i}/19398.pbf'),
        ),
      );
      expect(peak, lessThanOrEqualTo(3));
      var bytes = 0;
      await for (final f in directory.list()) {
        bytes += (await f.stat()).size;
      }
      expect(bytes, lessThanOrEqualTo(8));
      cache.cerrar();
    },
  );

  test(
    'servidor permite solo XYZ válidos y no acepta una URL como destino',
    () async {
      var requests = 0;
      final cache = almacen((z, x, y) async {
        requests++;
        return Uint8List.fromList([5, 6]);
      });
      final server = await ServidorMapaLocal.abrir(assets: {}, teselas: cache);
      final client = HttpClient();
      try {
        final response = await (await client.getUrl(
          server.inicio.resolve('contexto/15/11103/19396.pbf'),
        )).close();
        expect(response.statusCode, 200);
        await response.drain<void>();
        expect(requests, 0);
        final online = await (await client.getUrl(
          server.inicio.resolve('contexto/15/11108/19398.pbf'),
        )).close();
        expect(online.statusCode, 200);
        await online.drain<void>();
        expect(requests, 1);
        for (final path in [
          'contexto/16/11103/19396.pbf',
          'contexto/15/32768/0.pbf',
          'contexto/15/-1/0.pbf',
          'contexto/https://example.com',
          '../contexto/15/1/1.pbf',
        ]) {
          final rejected = await (await client.getUrl(
            server.inicio.resolve(path),
          )).close();
          expect(rejected.statusCode, 404, reason: path);
          await rejected.drain<void>();
        }
        expect(requests, 1);
      } finally {
        client.close(force: true);
        await server.cerrar();
      }
    },
  );
}
