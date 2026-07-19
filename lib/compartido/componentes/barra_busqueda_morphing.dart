import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

class BarraBusquedaMorphing extends StatelessWidget {
  final double progress;
  final VoidCallback onOpen;

  const BarraBusquedaMorphing({
    super.key,
    required this.progress,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = progress.clamp(0.0, 1.0);
    final textOpacity = ((normalized - 0.20) / 0.80).clamp(0.0, 1.0);
    final w = MediaQuery.of(context).size.width;
    final collapsedW = 48.0;
    final expandedW = w - 32;
    final width = lerpDouble(collapsedW, expandedW, normalized)!;

    return Align(
      alignment: Alignment.centerRight,
      child: Semantics(
        button: true,
        label: 'Abrir búsqueda',
        child: GestureDetector(
          onTap: onOpen,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            width: width,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD0D0CE)),
              boxShadow: [
                if (normalized > 0.01)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08 * normalized),
                    blurRadius: 10 * normalized,
                    offset: Offset(0, 3 * normalized),
                  ),
              ],
            ),
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: 0,
              maxWidth: expandedW,
              child: SizedBox(
                width: expandedW,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 46,
                      child: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (normalized > 0.15)
                      Expanded(
                        child: Opacity(
                          opacity: textOpacity,
                          child: const Text(
                            'Buscar puntos, publicaciones...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF8A8A8A),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    if (normalized > 0.50)
                      Opacity(
                        opacity: textOpacity,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 14),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Color(0xFF8A8A8A),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
