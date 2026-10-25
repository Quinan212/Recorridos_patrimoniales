import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/pantalla_inicio_alejo.dart'
    show AlejoEditorialCover;
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/mapa_3d/pantalla_mapa_3d.dart';
import 'package:recorridos_patrimoniales/modulos/alejo_patrimonio/servicios/repositorio_patrimonio.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final puntos = context.watch<RepositorioPatrimonio>().puntos;
    final mediaQuery = MediaQuery.of(context);
    final usableHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    final coverHeight = (usableHeight - 36.0).clamp(580.0, 860.0).toDouble();

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
            child: SizedBox(
              height: coverHeight,
              child: AlejoEditorialCover(
                cantidadPuntos: puntos.length,
                onTapRoute: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaMapa3D(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
