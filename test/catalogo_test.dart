import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componentes/distancia_punto.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sin ubicación real no se muestra una distancia inventada', () {
    final metros = distanciaGeografica(null, const LatLng(-31.39, -58.01));
    expect(metros, isNull);
    expect(etiquetaDistancia(metros), 'Ubicación no disponible');
  });

  test(
    'la distancia se calcula desde el origen recibido y aclara línea recta',
    () {
      const destino = LatLng(0, 0.01);
      final metros = distanciaGeografica(const LatLng(0, 0), destino)!;
      expect(metros, closeTo(1113, 5));
      expect(etiquetaDistancia(metros), '≈ 1,1 km en línea recta');
      expect(distanciaGeografica(destino, destino), 0);
      expect(etiquetaDistancia(0), '≈ 0 m en línea recta');
      expect(etiquetaDistancia(450), '≈ 450 m en línea recta');
    },
  );

  test('valores inválidos no se presentan como distancias válidas', () {
    for (final valor in [double.nan, double.infinity, -1.0]) {
      expect(etiquetaDistancia(valor), 'Ubicación no disponible');
    }
  });

  test(
    'catálogo con identificadores únicos, coordenadas válidas y referencias',
    () {
      expect(puntosAlejo.map((p) => p.id).toSet().length, puntosAlejo.length);
      for (final punto in puntosAlejo) {
        expect(punto.lat, inInclusiveRange(-90, 90), reason: punto.id);
        expect(punto.lng, inInclusiveRange(-180, 180), reason: punto.id);
        expect(punto.fuentes, isNotEmpty, reason: punto.id);
        expect(punto.revisionEditorial, isNotEmpty, reason: punto.id);
        for (final fuente in punto.fuentes) {
          expect(Uri.parse(fuente.url).scheme, 'https');
          expect(fuente.referencia, isNotEmpty);
        }
        if (punto.urlsImagenes.isNotEmpty) {
          expect(punto.procedenciaImagenes, isNotEmpty, reason: punto.id);
        }
      }
    },
  );

  test('Liga: descripción completa y dirección de la ficha de la UTN', () {
    final liga = puntosAlejo.singleWhere(
      (p) => p.id == 'r1-liga-argentina-prestamos-mutuos',
    );
    expect(liga.direccion, contains('Entre Ríos 487'));
    expect(liga.descripcion, contains('viviendas y locales comerciales'));
    expect(liga.descripcion.endsWith('.'), isTrue);
    expect(liga.fuentes.single.url, endsWith('#page=56'));
  });

  test('Péndola: interpretación atribuida y nombres normalizados', () {
    final casa = puntosAlejo.singleWhere(
      (p) => p.id == 'r1-casa-del-dr-pendola-diaz',
    );
    expect(casa.nombre, 'Casa del Dr. Péndola Díaz');
    expect(casa.direccion, startsWith('Güemes'));
    expect(casa.descripcion, contains('Bruno, Cáseres y Sota'));
    expect(casa.fuentes.single.referencia, contains('página 11'));
  });

  test('Suburo y Masvernat conservan las vistas cotejadas con sus fichas', () {
    final suburo = puntosAlejo.singleWhere((p) => p.id == 'r1-casa-suburo');
    final masvernat = puntosAlejo.singleWhere(
      (p) => p.id == 'r1-casa-masvernat',
    );
    expect(suburo.urlsImagenes, [
      for (final n in ['5146', '5148'])
        'assets/imagenes/puntos/casa-suburo/Screenshot_177682$n.jpg',
    ]);
    expect(masvernat.urlsImagenes, [
      for (final n in ['3895', '3897'])
        'assets/imagenes/puntos/casa-masvernat/Screenshot_177682$n.jpg',
      'assets/imagenes/puntos/casa-masvernat/Screenshot_1776825150.jpg',
    ]);
  });

  test(
    'todas las fotos locales existen, se decodifican y tienen contenido',
    () async {
      for (final ruta in puntosAlejo.expand((p) => p.urlsImagenes).toSet()) {
        final file = File(ruta);
        expect(file.existsSync(), isTrue, reason: ruta);
        final codec = await ui.instantiateImageCodec(
          await file.readAsBytes(),
          targetWidth: 64,
        );
        final frame = await codec.getNextFrame();
        final imagen = frame.image;
        final bytes = (await imagen.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        var minimo = 255;
        var maximo = 0;
        for (var i = 0; i < bytes.lengthInBytes; i += 4) {
          final gris = bytes.getUint8(i);
          if (gris < minimo) minimo = gris;
          if (gris > maximo) maximo = gris;
        }
        expect(
          maximo - minimo,
          greaterThan(10),
          reason: '$ruta: imagen vacía o uniforme',
        );
        imagen.dispose();
        codec.dispose();
      }
    },
  );
}
