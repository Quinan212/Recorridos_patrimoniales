import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/alejo_home_screen.dart';
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/services/audio_service.dart';
import 'package:recorridos_patrimoniales/features/alejo_patrimonio/audio_player_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService().init();
  runApp(const AlejoApp());
}

class AlejoApp extends StatelessWidget {
  const AlejoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioProvider(),
      child: MaterialApp(
        title: 'Recorridos Patrimoniales',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF1A1A1A),
        ),
        builder: (context, child) {
          return GlobalAudioOverlay(child: child ?? const SizedBox());
        },
        home: const AlejoHomeScreen(),
      ),
    );
  }
}

class GlobalAudioOverlay extends StatelessWidget {
  final Widget child;

  const GlobalAudioOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        return Stack(
          children: [
            child,
            if (audio.hasAudio)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _GlobalFloatingPlayer(),
              ),
          ],
        );
      },
    );
  }
}

class _GlobalFloatingPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final double progress = audio.duration.inMilliseconds > 0
        ? (audio.position.inMilliseconds / audio.duration.inMilliseconds)
              .clamp(0.0, 1.0)
        : 0.0;

    // DefaultTextStyle nuclear: corta CUALQUIER decoración heredada del árbol
    // padre (el MaterialApp.builder está fuera del contexto Material normal,
    // por eso el Text heredaba el underline amarillo del DefaultTextStyle raíz).
    // Material(transparency) reinicia el contexto sin agregar fondo de color.
    return DefaultTextStyle(
      style: const TextStyle(
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
        decorationThickness: 0,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ícono
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.headphones,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                // Título + barra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Título sin ningún subrayado ──
                      Text(
                        audio.currentTitle ?? 'Audio',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                          decorationColor: Colors.transparent,
                          decorationThickness: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      // ── Barra de progreso: solo Containers, cero tema ──
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            height: 3,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD32F2F),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Play / Pause
                GestureDetector(
                  onTap: audio.togglePlayPause,
                  child: Icon(
                    audio.isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 6),
                // Cerrar
                GestureDetector(
                  onTap: audio.stop,
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.5),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
