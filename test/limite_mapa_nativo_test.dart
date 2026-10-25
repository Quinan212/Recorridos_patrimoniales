import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/catalogo_mapa_3d.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/limite_area.dart';

void main() {
  final area =
      jsonDecode(
            File('assets/mapa_3d/area-coverage.geojson').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final limite = LimiteAreaMapa(area);
  final data = jsonDecode(
    File('assets/mapa_3d/area-catalog.json').readAsStringSync(),
  );
  final catalogo = CatalogoMapa3D(
    (data['points'] as List).cast<Map<String, dynamic>>(),
  );
  test(
    'Los 24 puntos quedan dentro y conservan exactamente sus coordenadas',
    () {
      for (final p in catalogo.reconciliar(puntosAlejo)) {
        expect(
          limite.contiene(p.punto.lng, p.punto.lat),
          true,
          reason: p.punto.nombre,
        );
        expect(limite.limitar(p.punto.lng, p.punto.lat), [
          p.punto.lng,
          p.punto.lat,
        ]);
      }
    },
  );
  test(
    'Desplazamientos fuera del ovalo regresan a su interior en las cuatro direcciones',
    () {
      for (final p in [
        [-58.15, -31.38],
        [-57.95, -31.38],
        [-58.04, -31.32],
        [-58.04, -31.45],
      ]) {
        expect(limite.contiene(p[0], p[1]), false);
        final result = limite.limitar(p[0], p[1]);
        expect(limite.contiene(result[0], result[1]), true);
        expect(limite.limitar(result[0], result[1]), result);
      }
    },
  );
}
