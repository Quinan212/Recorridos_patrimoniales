import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

/// Distancia geográfica: no representa un recorrido ni un tiempo a pie.
double? distanciaGeografica(LatLng? origen, LatLng destino) {
  if (origen == null) return null;
  return const Distance().as(LengthUnit.Meter, origen, destino);
}

String etiquetaDistancia(double? metros) {
  if (metros == null || !metros.isFinite || metros < 0) {
    return 'Ubicación no disponible';
  }
  final valor = metros < 1000
      ? '${metros.round()} m'
      : '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  return '≈ $valor en línea recta';
}

class DistanciaPunto extends StatelessWidget {
  const DistanciaPunto({
    super.key,
    required this.origen,
    required this.destino,
  });

  final LatLng? origen;
  final LatLng destino;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          origen == null ? Icons.location_off_outlined : Icons.straighten,
          size: 13,
          color: const Color(0xFF888888),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            etiquetaDistancia(distanciaGeografica(origen, destino)),
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
