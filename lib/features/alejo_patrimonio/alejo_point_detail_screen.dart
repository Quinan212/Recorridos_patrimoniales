import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recorridos_patrimoniales/data/points_data.dart';
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/audio_player_widget.dart';
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/alejo_map_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  PANTALLA DE DETALLE DEL PUNTO PATRIMONIAL
// ─────────────────────────────────────────────────────────────────────────────
class AlejoPointDetailScreen extends StatefulWidget {
  final PatrimonioPoint point;

  const AlejoPointDetailScreen({super.key, required this.point});

  @override
  State<AlejoPointDetailScreen> createState() => _AlejoPointDetailScreenState();
}

class _AlejoPointDetailScreenState extends State<AlejoPointDetailScreen> {
  final PageController _carouselController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = widget.point.imageUrls.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Header con carrusel ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: imageCount > 0 ? 310 : 120,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A1A),
            automaticallyImplyLeading: false,
            // Botón atrás: glassmorphism, legible sobre cualquier fondo
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: imageCount > 0
                  ? _buildCarousel(context, imageCount)
                  : Container(
                      color: const Color(0xFF1A1A1A),
                      child: const Center(
                        child: Icon(
                          Icons.architecture,
                          size: 80,
                          color: Colors.white24,
                        ),
                      ),
                    ),
            ),
          ),

          // ── Contenido ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    widget.point.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Dirección
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.point.address,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  // Línea divisora roja
                  Container(height: 3, width: 48, color: const Color(0xFFD32F2F)),
                  const SizedBox(height: 22),

                  // Descripción
                  if (widget.point.description.isNotEmpty) ...[
                    Text(
                      'DESCRIPCIÓN',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.point.description,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        height: 1.7,
                        color: const Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Mapa miniatura
                  Text(
                    'UBICACIÓN',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMiniMap(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Botón reproducir audio ────────────────────────────────────────────
      bottomNavigationBar: _buildAudioBar(context),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  CARRUSEL DE IMÁGENES con indicadores y toque para fullscreen
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildCarousel(BuildContext context, int count) {
    return Stack(
      children: [
        // Páginas de imágenes
        PageView.builder(
          controller: _carouselController,
          itemCount: count,
          onPageChanged: (i) => setState(() => _currentImageIndex = i),
          itemBuilder: (context, index) {
            final tag = 'img_${widget.point.id}_$index';
            return GestureDetector(
              onTap: () => _openFullscreen(context, index),
              child: Hero(
                tag: tag,
                child: Image.network(
                  widget.point.imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF222222),
                    child: const Icon(
                      Icons.architecture,
                      color: Colors.white24,
                      size: 60,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Gradiente inferior (da profundidad y hace legibles los indicadores)
        // Usamos IgnorePointer para que los toques traspasen el gradiente
        // y lleguen a la imagen (permitiendo scrollear y abrir en pantalla completa).
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.55, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Contador "2 / 5" — arriba derecha
        if (count > 1)
          Positioned(
            top: 12,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                '${_currentImageIndex + 1} / $count',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Indicadores de puntos — abajo centro
        if (count > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (i) {
                final isActive = i == _currentImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

        // Ícono expand — abajo derecha
        Positioned(
          bottom: 12,
          right: 14,
          child: GestureDetector(
            onTap: () => _openFullscreen(context, _currentImageIndex),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  ABRIR VISOR FULLSCREEN
  // ─────────────────────────────────────────────────────────────────────
  void _openFullscreen(BuildContext context, int startIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => _FullscreenImageViewer(
          imageUrls: widget.point.imageUrls,
          initialIndex: startIndex,
          pointId: widget.point.id,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  MAPA MINIATURA
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildMiniMap(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlejoMapScreen(initialPointId: widget.point.id),
        ),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(widget.point.lat, widget.point.lng),
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'ar.maillet.recorridos_patrimoniales',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(widget.point.lat, widget.point.lng),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.architecture,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Overlay con hint
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Ver en mapa',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //  BARRA DE AUDIO INFERIOR
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildAudioBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            final audioUrl = widget.point.audioUrl ??
                "https://drive.usercontent.google.com/uc?id=1YOZNGs9p7ejUS6WAgPcsnG_bNpUs83Wx&export=download";
            playAudioGlobal(context, widget.point.name, audioUrl);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.headphones, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'REPRODUCIR AUDIO',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  VISOR FULLSCREEN DE IMÁGENES
//  • Hero animation desde el carrusel
//  • Deslizar entre fotos (PageView)
//  • Pinch-to-zoom en cada imagen (InteractiveViewer)
//  • Swipe vertical para cerrar
// ─────────────────────────────────────────────────────────────────────────────
class _FullscreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String pointId;

  const _FullscreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
    required this.pointId,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _showUi = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    // Pantalla completa inmersiva
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showUi = !_showUi),
        child: Stack(
          children: [
            // ── Páginas de imágenes con zoom ──
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                final tag = 'img_${widget.pointId}_$index';
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  panEnabled: true,
                  child: Center(
                    child: Hero(
                      tag: tag,
                      child: Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white30,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── UI superpuesta (se oculta al tocar) ──
            AnimatedOpacity(
              opacity: _showUi ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  // Gradiente superior
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Botón cerrar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Contador
                            if (widget.imageUrls.length > 1)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentIndex + 1} / ${widget.imageUrls.length}',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(),
                            // X cerrar
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Indicadores de puntos inferiores
                  if (widget.imageUrls.length > 1)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.imageUrls.length,
                            (i) {
                              final active = i == _currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
