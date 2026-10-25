import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'almacen_teselas_mapa.dart';

/// Sirve assets permitidos y teselas de un proveedor fijo en el loopback.
class ServidorMapaLocal {
  ServidorMapaLocal._(this._server, this._token, this._assets, this._loader);

  final HttpServer _server;
  final String _token;
  final Set<String> _assets;
  final Future<ByteData> Function(String) _loader;
  Map<String, String> _imagenes = {};
  AlmacenTeselasMapa? _teselas;

  void actualizarImagenes(Map<String, String> imagenes) {
    _imagenes = {
      for (final entry in imagenes.entries)
        if (RegExp(r'^imagenes/\d+\.jpg$').hasMatch(entry.key) &&
            entry.value.startsWith('assets/imagenes/puntos/') &&
            !entry.value.split('/').any((part) => part == '..' || part == '.'))
          entry.key: entry.value,
    };
  }

  Uri get inicio =>
      Uri.parse('http://127.0.0.1:${_server.port}/$_token/index.html');

  static Future<ServidorMapaLocal> abrir({
    Set<String>? assets,
    Future<ByteData> Function(String)? loader,
    Map<String, String> imagenes = const {},
    bool mapaContinuo = false,
    AlmacenTeselasMapa? teselas,
  }) async {
    final cargar = loader ?? rootBundle.load;
    final lista =
        assets ??
        (jsonDecode(
                  await rootBundle.loadString('assets/mapa_3d/asset-list.json'),
                )
                as List)
            .cast<String>()
            .toSet();
    final almacen =
        teselas ??
        (mapaContinuo ? await AlmacenTeselasMapa.abrir(lista) : null);
    late HttpServer server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    } catch (_) {
      almacen?.cerrar();
      rethrow;
    }
    final random = Random.secure();
    final token = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final servicio = ServidorMapaLocal._(server, token, lista, cargar);
    servicio._teselas = almacen;
    servicio.actualizarImagenes(imagenes);
    server.listen(servicio._servir);
    return servicio;
  }

  bool permite(Uri uri) =>
      uri.scheme == inicio.scheme &&
      uri.host == inicio.host &&
      uri.port == inicio.port &&
      uri.path.startsWith('/$_token/');

  Future<void> _servir(HttpRequest request) async {
    final response = request.response;
    try {
      final prefix = '/$_token/';
      final path = '/${request.uri.pathSegments.join('/')}';
      final nombre = path.startsWith(prefix)
          ? path.substring(prefix.length)
          : '';
      if (!['GET', 'HEAD'].contains(request.method)) {
        response.statusCode = HttpStatus.methodNotAllowed;
      } else if ((!_assets.contains(nombre) &&
              !_imagenes.containsKey(nombre) &&
              !(_teselas != null && AlmacenTeselasMapa.esRuta(nombre))) ||
          nombre.split('/').any((part) => part == '..' || part == '.')) {
        response.statusCode = HttpStatus.notFound;
      } else {
        response.headers.set('X-Content-Type-Options', 'nosniff');
        response.headers.set('Cache-Control', 'private, max-age=86400');
        response.headers.set(
          'Content-Security-Policy',
          "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; worker-src 'self' blob:; img-src 'self' data: blob:; connect-src 'self'; font-src 'self'; object-src 'none'; frame-ancestors 'none'",
        );
        final recurso = _imagenes[nombre] ?? 'assets/mapa_3d/$nombre';
        final extension = recurso.split('.').last.toLowerCase();
        response.headers.set('Content-Type', switch (extension) {
          'html' => 'text/html; charset=utf-8',
          'js' => 'application/javascript; charset=utf-8',
          'css' => 'text/css; charset=utf-8',
          'json' || 'geojson' => 'application/json; charset=utf-8',
          'pbf' => 'application/octet-stream',
          'jpg' || 'jpeg' => 'image/jpeg',
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => 'text/plain; charset=utf-8',
        });
        if (_teselas != null && AlmacenTeselasMapa.esRuta(nombre)) {
          final bytes = await _teselas!.obtener(nombre);
          if (bytes == null) {
            response.statusCode = HttpStatus.serviceUnavailable;
            response.headers.set('Cache-Control', 'no-store');
          } else if (bytes.isEmpty) {
            response.statusCode = HttpStatus.noContent;
          } else {
            response.contentLength = bytes.length;
            if (request.method == 'GET') response.add(bytes);
          }
        } else {
          final data = await _loader(recurso);
          response.contentLength = data.lengthInBytes;
          if (request.method == 'GET') {
            response.add(
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            );
          }
        }
      }
    } catch (_) {
      // Al volver atrás el motor puede haber cancelado una petición en curso.
      try {
        response.statusCode = HttpStatus.internalServerError;
      } catch (_) {}
    } finally {
      try {
        await response.close();
      } catch (_) {}
    }
  }

  Future<void> cerrar() async {
    _teselas?.cerrar();
    await _server.close(force: true);
  }
}
