import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Proveedor global de audio para toda la app
class AudioProvider extends ChangeNotifier {
  static final AudioProvider _instance = AudioProvider._internal();
  factory AudioProvider() => _instance;
  AudioProvider._internal() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();
  String? _currentTitle;
  String? _currentUrl;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  String? get currentTitle => _currentTitle;
  String? get currentUrl => _currentUrl;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasAudio => _currentUrl != null;

  AudioPlayer get player => _player;

  Future<void> _init() async {
    _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
        _player.seek(Duration.zero);
        _player.pause();
      }
      notifyListeners();
    });
  }

  Future<void> play(String title, String url) async {
    if (_currentUrl != url) {
      _currentTitle = title;
      _currentUrl = url;
      notifyListeners();
    }
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    _currentTitle = null;
    _currentUrl = null;
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }
}

/// Helper para usar el audio desde cualquier parte de la app
void playAudioGlobal(BuildContext context, String title, String url) {
  final audio = Provider.of<AudioProvider>(context, listen: false);
  audio.play(title, url);
}

/// Widget que envuelve cualquier pantalla y muestra el reproductor flotante
class AudioFloatingWrapper extends StatelessWidget {
  final Widget child;

  const AudioFloatingWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        return Stack(
          children: [
            child,
            if (audio.hasAudio)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _FloatingPlayerWidget(),
              ),
          ],
        );
      },
    );
  }
}

/// Altura total aproximada del reproductor flotante (para que otros widgets se ubiquen sobre él)
const double kFloatingPlayerHeight = 90.0;

class _FloatingPlayerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();

    // Progreso entre 0.0 y 1.0 — calculado manualmente, sin LinearProgressIndicator
    final double progress = audio.duration.inMilliseconds > 0
        ? (audio.position.inMilliseconds / audio.duration.inMilliseconds)
              .clamp(0.0, 1.0)
        : 0.0;

    // ══════════════════════════════════════════════════════════
    // DefaultTextStyle nuclear: resetea CUALQUIER decoración de
    // texto heredada del árbol padre antes de que llegue a los
    // widgets Text hijos. Ningún tema puede sobrescribir esto.
    // Material(transparency) reinicia el contexto sem interferir
    // con el color de fondo del Container.
    // ══════════════════════════════════════════════════════════
    return DefaultTextStyle(
      style: const TextStyle(
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
        decorationThickness: 0,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                // Ícono de auriculares
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.headphones,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Título + barra de progreso + tiempo
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Título ──
                      Text(
                        audio.currentTitle ?? 'Audio',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                          decorationColor: Colors.transparent,
                          decorationThickness: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 4),
                      // ── Tiempo ──
                      Text(
                        '${_formatDuration(audio.position)} / ${_formatDuration(audio.duration)}',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 10,
                          decoration: TextDecoration.none,
                          decorationColor: Colors.transparent,
                          decorationThickness: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Botones play/pause y cerrar
                IconButton(
                  onPressed: audio.togglePlayPause,
                  icon: Icon(
                    audio.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: audio.stop,
                  icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
