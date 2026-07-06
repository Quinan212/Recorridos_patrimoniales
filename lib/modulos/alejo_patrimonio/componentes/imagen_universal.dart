import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImagenUniversal extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? reemplazoVisual;
  final int? anchoCache;
  final int? altoCache;
  final FilterQuality calidadFiltro;

  const ImagenUniversal({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.reemplazoVisual,
    this.anchoCache,
    this.altoCache,
    this.calidadFiltro = FilterQuality.low,
  });

  @override
  Widget build(BuildContext context) {
    final esRecurso = url.startsWith('assets/');

    if (esRecurso) {
      return Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: anchoCache,
        cacheHeight: altoCache,
        filterQuality: calidadFiltro,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            debugPrint('No se pudo cargar la imagen local "$url": $error');
          }
          return _armarPlaceholder();
        },
      );
    } else {
      return Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: anchoCache,
        cacheHeight: altoCache,
        filterQuality: calidadFiltro,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            debugPrint('No se pudo cargar la imagen remota "$url": $error');
          }
          return _armarPlaceholder();
        },
      );
    }
  }

  Widget _armarPlaceholder() {
    return reemplazoVisual ??
        Container(
          color: const Color(0xFF222222),
          child: const Icon(
            Icons.architecture,
            color: Colors.white24,
            size: 40,
          ),
        );
  }
}
