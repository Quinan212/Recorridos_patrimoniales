import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Prioriza la zona incluida en la app y conserva los sectores visitados.
/// Nunca acepta URLs arbitrarias ni carga la ciudad entera en memoria.
class AlmacenTeselasMapa {
  AlmacenTeselasMapa({
    required this.assets,
    required this.directorio,
    required this.loader,
    required this.descargar,
    this.maxBytes = 24 * 1024 * 1024,
    this.alCerrar,
  });

  final Set<String> assets;
  final Directory directorio;
  final Future<ByteData> Function(String) loader;
  final Future<Uint8List?> Function(int z, int x, int y) descargar;
  final int maxBytes;
  final void Function()? alCerrar;
  final _pendientes = <String, Future<Uint8List?>>{};
  final _espera = Queue<Completer<void>>();
  int _activas = 0;
  bool _cerrado = false;
  Future<void> _escrituras = Future<void>.value();

  static Future<AlmacenTeselasMapa> abrir(Set<String> assets) async {
    final directory = await getApplicationCacheDirectory();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    const key = String.fromEnvironment('MAPTILER_KEY');
    var reintentarDesde = DateTime.fromMillisecondsSinceEpoch(0);
    return AlmacenTeselasMapa(
      assets: assets,
      directorio: Directory('${directory.path}/mapa-planet-v4'),
      loader: rootBundle.load,
      alCerrar: () => client.close(force: true),
      descargar: (z, x, y) async {
        if (key.isEmpty || DateTime.now().isBefore(reintentarDesde)) {
          return null;
        }
        HttpClientRequest? request;
        try {
          final uri = Uri.https('api.maptiler.com', '/tiles/v4/$z/$x/$y.pbf', {
            'key': key,
          });
          request = await client
              .getUrl(uri)
              .timeout(const Duration(seconds: 8));
          request.followRedirects = false;
          request.headers.set('Origin', 'http://127.0.0.1:8765');
          final response = await request.close().timeout(
            const Duration(seconds: 8),
          );
          if (response.statusCode == HttpStatus.noContent) return Uint8List(0);
          if (response.statusCode != HttpStatus.ok) {
            await response.drain<void>();
            throw const HttpException('Cartografía no disponible');
          }
          final bytes = BytesBuilder(copy: false);
          await for (final part in response.timeout(
            const Duration(seconds: 8),
          )) {
            bytes.add(part);
            if (bytes.length > 2 * 1024 * 1024) {
              throw const HttpException('Tesela demasiado grande');
            }
          }
          return bytes.takeBytes();
        } catch (_) {
          request?.abort();
          reintentarDesde = DateTime.now().add(const Duration(seconds: 10));
          return null;
        }
      },
    );
  }

  static bool esRuta(String path) {
    final match = RegExp(
      r'^contexto/(\d{1,2})/(\d+)/(\d+)\.pbf$',
    ).firstMatch(path);
    if (match == null) return false;
    final z = int.tryParse(match[1]!),
        x = int.tryParse(match[2]!),
        y = int.tryParse(match[3]!);
    return z != null &&
        z <= 15 &&
        x != null &&
        y != null &&
        x < (1 << z) &&
        y < (1 << z);
  }

  Future<Uint8List?> obtener(String path) {
    if (_cerrado || !esRuta(path)) return Future.value(null);
    return _pendientes.putIfAbsent(path, () async {
      try {
        return await _obtener(path);
      } finally {
        _pendientes.remove(path);
      }
    });
  }

  Future<Uint8List?> _obtener(String path) async {
    if (assets.contains(path)) {
      final data = await loader('assets/mapa_3d/$path');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    final parts = path.split('/');
    final z = int.parse(parts[1]),
        x = int.parse(parts[2]),
        y = int.parse(parts[3].split('.').first);
    final file = File('${directorio.path}/$z-$x-$y.pbf');
    try {
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        unawaited(file.setLastModified(DateTime.now()).catchError((_) => file));
        return bytes;
      }
    } catch (_) {}
    if (_activas >= 3) {
      final turn = Completer<void>();
      _espera.add(turn);
      await turn.future;
    } else {
      _activas++;
    }
    try {
      if (_cerrado) return null;
      final bytes = await descargar(z, x, y);
      if (bytes != null && !_cerrado) {
        _escrituras = _escrituras
            .then((_) async {
              if (_cerrado) return;
              await directorio.create(recursive: true);
              await file.writeAsBytes(bytes, flush: false);
              await _reducirCache();
            })
            .catchError((_) {});
        await _escrituras;
      }
      return bytes;
    } catch (_) {
      return null;
    } finally {
      if (_espera.isNotEmpty) {
        _espera.removeFirst().complete();
      } else {
        _activas--;
      }
    }
  }

  Future<void> _reducirCache() async {
    final files = <({File file, FileStat stat})>[];
    var total = 0;
    await for (final item in directorio.list()) {
      if (item is! File ||
          !RegExp(r'[/\\]\d+-\d+-\d+\.pbf$').hasMatch(item.path)) {
        continue;
      }
      final stat = await item.stat();
      total += stat.size;
      files.add((file: item, stat: stat));
    }
    files.sort((a, b) => a.stat.modified.compareTo(b.stat.modified));
    for (final item in files) {
      if (total <= maxBytes) break;
      await item.file.delete();
      total -= item.stat.size;
    }
  }

  void cerrar() {
    _cerrado = true;
    alCerrar?.call();
    while (_espera.isNotEmpty) {
      _espera.removeFirst().complete();
    }
  }
}
