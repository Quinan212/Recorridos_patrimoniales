import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/datos/datos_puntos.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_detalle_punto_alejo.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/componentes/imagen_universal.dart';

class PantallaInicioAlejo extends StatefulWidget {
  const PantallaInicioAlejo({super.key});

  @override
  State<PantallaInicioAlejo> createState() => _PantallaInicioAlejoState();
}

class _PantallaInicioAlejoState extends State<PantallaInicioAlejo> {
  @override
  Widget build(BuildContext context) {
    final puntos = context.watch<RepositorioPatrimonio>().puntos;
    final puntosConImagenes = puntos
        .where((p) => p.urlsImagenes.isNotEmpty)
        .toList();
    final puntoDestacado = puntosConImagenes.firstWhere(
      (p) =>
          p.id == 'r1-casa-del-dr-pendola-diaz' ||
          p.nombre.toLowerCase().contains('pendola'),
      orElse: () =>
          puntosConImagenes.isNotEmpty ? puntosConImagenes.first : puntos.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.network(
                'https://i.postimg.cc/XJ658GS4/wqeqwe.png',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                cacheWidth: 1200,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          SafeArea(
            top: true,
            bottom: true,
            child: CustomScrollView(
              clipBehavior: Clip.hardEdge,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 360;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visitas autoguiadas',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Obras Arquitectonicas',
                                style: GoogleFonts.inter(
                                  fontSize: isNarrow ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 204,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: puntosConImagenes.length,
                      itemBuilder: (context, index) {
                        return _armarTarjetaHorizontalChica(
                          context,
                          puntosConImagenes[index],
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visita obligada',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _armarTarjetaDestacada(context, puntoDestacado),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
                    child: Text(
                      'Descubre toda la obra de Alejo Martinez en la ciudad',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = 12.0;
                        final cardWidth = (constraints.maxWidth - spacing) / 2;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: 14,
                          children: puntosConImagenes
                              .map((punto) {
                                return SizedBox(
                                  width: cardWidth,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PantallaDetallePuntoAlejo(
                                                punto: punto,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: ColorFiltered(
                                              colorFilter:
                                                  const ColorFilter.matrix([
                                                    0.2126,
                                                    0.7152,
                                                    0.0722,
                                                    0,
                                                    0,
                                                    0.2126,
                                                    0.7152,
                                                    0.0722,
                                                    0,
                                                    0,
                                                    0.2126,
                                                    0.7152,
                                                    0.0722,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    1,
                                                    0,
                                                  ]),
                                              child: ImagenUniversal(
                                                url: punto.urlsImagenes.first,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                anchoCache: 300,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          punto.nombre,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1A1A1A),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .toList(growable: false),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _armarTarjetaHorizontalChica(
    BuildContext context,
    PuntoPatrimonial punto,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaDetallePuntoAlejo(punto: punto),
          ),
        );
      },
      child: Container(
        width: 152,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImagenUniversal(
                  url: punto.urlsImagenes.first,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  anchoCache: 300,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              punto.nombre,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _armarTarjetaDestacada(BuildContext context, PuntoPatrimonial punto) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaDetallePuntoAlejo(punto: punto),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = (constraints.maxWidth * 0.72).clamp(260.0, 360.0);
          return Container(
            width: double.infinity,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.2),
                        BlendMode.darken,
                      ),
                      child: ImagenUniversal(
                        url: punto.urlsImagenes.first,
                        fit: BoxFit.cover,
                        anchoCache: 800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Primera obra moderna de Argentina',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          punto.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '211 m',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.near_me,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '610 m',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _armarTarjetaRecorrido(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String count,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    ),
  );
}

class AlejoEditorialCover extends StatelessWidget {
  const AlejoEditorialCover({
    super.key,
    required this.cantidadPuntos,
    required this.onTapRoute,
  });

  final int cantidadPuntos;
  final VoidCallback onTapRoute;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD32F2F).withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF5F5F3).withValues(alpha: 0.90),
                    const Color(0xFFF5F5F3).withValues(alpha: 0.72),
                    const Color(0xFFF5F5F3),
                  ],
                  stops: const [0.0, 0.68, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            top: true,
            bottom: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final scale = (availableHeight / 820.0).clamp(0.72, 1.0);
                final topPadding = lerpDouble(24, 48, scale)!;
                final titleSize = lerpDouble(42, 60, scale)!;
                final subtitleSize = lerpDouble(13, 18, scale)!;
                final letterSpacing = lerpDouble(2.2, 4, scale)!;
                final lift = -lerpDouble(18, 56, scale)!;
                final gap = lerpDouble(10, 18, scale)!;
                final footerGap = lerpDouble(8, 16, scale)!;

                return Padding(
                  padding: EdgeInsets.fromLTRB(30, topPadding, 30, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'ALEJO\nMARTINEZ',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      SizedBox(height: gap),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 4,
                          width: lerpDouble(44, 60, scale)!,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                      SizedBox(height: gap),
                      Text(
                        'LA VANGUARDIA\nRACIONALISTA EN\nCONCORDIA',
                        style: GoogleFonts.inter(
                          fontSize: subtitleSize,
                          letterSpacing: letterSpacing,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                      const Spacer(),
                      Transform.translate(
                        offset: Offset(0, lift),
                        child: _armarTarjetaRecorrido(
                          context,
                          title: 'RUTA DE LA INNOVACION',
                          subtitle: 'Obras fundacionales (1924-1931)',
                          count: '$cantidadPuntos puntos clave',
                          onTap: onTapRoute,
                        ),
                      ),
                      SizedBox(height: footerGap),
                      Transform.translate(
                        offset: Offset(0, lift),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'EDICION 2026',
                              style: GoogleFonts.inter(
                                fontSize: lerpDouble(9, 10, scale)!,
                                fontWeight: FontWeight.bold,
                                letterSpacing: lerpDouble(1.5, 2, scale)!,
                              ),
                            ),
                            Text(
                              'A',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
