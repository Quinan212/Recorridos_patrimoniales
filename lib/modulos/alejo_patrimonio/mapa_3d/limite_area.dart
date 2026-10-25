import 'dart:math' as math;

/// Límite geográfico del óvalo; nunca modifica las coordenadas del catálogo.
class LimiteAreaMapa {
  LimiteAreaMapa(Map<String, dynamic> geojson) {
    for (final feature in geojson['features'] as List) {
      final geometry = feature['geometry'] as Map;
      final polygons = geometry['type'] == 'MultiPolygon'
          ? geometry['coordinates'] as List
          : [geometry['coordinates']];
      for (final polygon in polygons) {
        _rings.add([
          for (final p in polygon[0] as List)
            [(p[0] as num).toDouble(), (p[1] as num).toDouble()],
        ]);
      }
    }
  }
  final _rings = <List<List<double>>>[];

  bool contiene(double lng, double lat) {
    for (final ring in _rings) {
      var inside = false;
      for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
        final a = ring[i], b = ring[j];
        if ((a[1] > lat) != (b[1] > lat) &&
            lng < (b[0] - a[0]) * (lat - a[1]) / (b[1] - a[1]) + a[0]) {
          inside = !inside;
        }
      }
      if (inside) return true;
    }
    return false;
  }

  List<double> limitar(double lng, double lat) {
    if (contiene(lng, lat)) return [lng, lat];
    final sx = math.cos(lat * math.pi / 180);
    var best = double.infinity;
    List<double>? result;
    for (final ring in _rings) {
      final cx = ring.fold<double>(0, (s, p) => s + p[0]) / ring.length;
      final cy = ring.fold<double>(0, (s, p) => s + p[1]) / ring.length;
      for (var i = 1; i < ring.length; i++) {
        final a = ring[i - 1], b = ring[i];
        final dx = (b[0] - a[0]) * sx, dy = b[1] - a[1];
        final length = dx * dx + dy * dy;
        if (length == 0) continue;
        final t = (((lng - a[0]) * sx * dx + (lat - a[1]) * dy) / length).clamp(
          0.0,
          1.0,
        );
        final x = a[0] + t * (b[0] - a[0]), y = a[1] + t * dy;
        final distance = math.pow((x - lng) * sx, 2) + math.pow(y - lat, 2);
        if (distance < best) {
          best = distance.toDouble();
          // Entrar unos metros en el óvalo evita un bucle de correcciones.
          final inward = math.sqrt(
            math.pow((cx - x) * sx, 2) + math.pow(cy - y, 2),
          );
          final fraction = math.min(1.0, .00005 / inward);
          result = [x + (cx - x) * fraction, y + (cy - y) * fraction];
        }
      }
    }
    return result!;
  }
}
