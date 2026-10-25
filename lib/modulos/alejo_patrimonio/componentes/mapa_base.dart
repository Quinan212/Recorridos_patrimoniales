import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

/// Misma fuente y caché para el mapa principal y los mapas de detalle.
class CapaMapaBase extends StatelessWidget {
  const CapaMapaBase({super.key});

  @override
  Widget build(BuildContext context) => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'ar.maillet.recorridos_patrimoniales',
    maxNativeZoom: 19,
    tileProvider: NetworkTileProvider(
      cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
        maxCacheSize: 250000000,
      ),
    ),
    keepBuffer: 1,
    panBuffer: 0,
    tileDisplay: const TileDisplay.instantaneous(),
  );
}

class AtribucionMapaBase extends StatelessWidget {
  const AtribucionMapaBase({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(4),
    child: InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => launchUrl(
        Uri.parse('https://www.openstreetmap.org/copyright'),
        mode: LaunchMode.externalApplication,
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Text(
          '© OpenStreetMap contributors',
          style: TextStyle(fontSize: 10, color: Color(0xFF333333)),
        ),
      ),
    ),
  );
}
