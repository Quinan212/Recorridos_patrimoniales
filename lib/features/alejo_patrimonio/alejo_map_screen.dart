import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/data/points_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/alejo_point_detail_screen.dart';
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/audio_player_widget.dart'
    show kFloatingPlayerHeight, playAudioGlobal, AudioProvider;
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/services/audio_service.dart';

class AlejoMapScreen extends StatefulWidget {
  final String? initialPointId;

  const AlejoMapScreen({super.key, this.initialPointId});

  @override
  State<AlejoMapScreen> createState() => _AlejoMapScreenState();
}

class _AlejoMapScreenState extends State<AlejoMapScreen> {
  final MapController _mapController = MapController();
  PatrimonioPoint? _selectedPoint;

  LatLng get _initialCenter {
    if (widget.initialPointId != null) {
      final point = alejoPoints.firstWhere(
        (p) => p.id == widget.initialPointId,
        orElse: () => alejoPoints.first,
      );
      return LatLng(point.lat, point.lng);
    }
    return const LatLng(-31.392, -58.020);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialPointId != null) {
      _selectedPoint = alejoPoints.firstWhere(
        (p) => p.id == widget.initialPointId,
        orElse: () => alejoPoints.first,
      );
    }
  }

  double _calculateDistance(PatrimonioPoint point) {
    const userLat = -31.392;
    const userLng = -58.020;
    const distance = Distance();
    return distance.as(
      LengthUnit.Meter,
      LatLng(userLat, userLng),
      LatLng(point.lat, point.lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final hasAudio = audio.hasAudio;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    // Tarjeta y barra suben cuando el reproductor está visible + la zona segura del sistema
    final cardBottom = (hasAudio ? kFloatingPlayerHeight + 8 + 16 : 16.0) + bottomPadding;
    final barBottom  = (hasAudio ? kFloatingPlayerHeight + 8 + 16 : 16.0) + bottomPadding;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: widget.initialPointId != null ? 16 : 14.5,
              maxZoom: 18,
              minZoom: 12,
              onTap: (_, __) {
                setState(() => _selectedPoint = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'ar.maillet.recorridos_patrimoniales',
              ),
              MarkerLayer(
                markers: alejoPoints.map((point) {
                  final isSelected = point.id == _selectedPoint?.id;
                  return Marker(
                    point: LatLng(point.lat, point.lng),
                    width: isSelected ? 55 : 45,
                    height: isSelected ? 55 : 45,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedPoint = point);
                      },
                      child: _buildMarker(point, isSelected),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Flecha atrás (10px debajo del Status Bar)
          Positioned(
            top: topPadding + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Barra inferior — solo cuando no hay punto seleccionado
          if (_selectedPoint == null)
            Positioned(
              bottom: barBottom,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.explore, color: Color(0xFFD32F2F), size: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ALEJO MARTÍNEZ',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Recorrido de la Innovación',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Tarjeta flotante del punto seleccionado
          if (_selectedPoint != null)
            Positioned(
              bottom: cardBottom,
              left: 16,
              right: 16,
              child: _buildPointCard(_selectedPoint!),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  MARCADOR en el mapa
  // ─────────────────────────────────────────
  Widget _buildMarker(PatrimonioPoint point, bool isSelected) {
    if (isSelected) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.architecture, color: Colors.white, size: 26),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[400]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: point.imageUrls.isNotEmpty
            ? Image.network(
                point.imageUrls.first,
                fit: BoxFit.cover,
                width: 41,
                height: 41,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 41,
      height: 41,
      color: Colors.grey[200],
      child: Icon(Icons.architecture, color: Colors.grey[600], size: 22),
    );
  }

  // ─────────────────────────────────────────
  //  TARJETA del punto seleccionado
  // ─────────────────────────────────────────
  Widget _buildPointCard(PatrimonioPoint point) {
    final distance = _calculateDistance(point);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlejoPointDetailScreen(point: point),
          ),
        );
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Foto: cuadrado propio con bordes redondeados y margen ──
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: point.imageUrls.isNotEmpty
                      ? Image.network(
                          point.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFEEEEEE),
                            child: Icon(
                              Icons.architecture,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFEEEEEE),
                          child: Icon(
                            Icons.architecture,
                            color: Colors.grey[400],
                            size: 28,
                          ),
                        ),
                ),
              ),
            ),

            // ── Nombre + distancia ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    point.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.navigation,
                        size: 13,
                        color: Color(0xFF888888),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${distance.round()} m',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Botón play circular ──
            GestureDetector(
              onTap: () {
                final audioUrl = point.audioUrl ??
                    "https://drive.usercontent.google.com/uc?id=1YOZNGs9p7ejUS6WAgPcsnG_bNpUs83Wx&export=download";
                playAudioGlobal(context, point.name, audioUrl);
              },
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
