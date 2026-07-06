import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Proveedor global de audio para toda la app
class ControladorAudio extends ChangeNotifier {
  static final ControladorAudio _instance = ControladorAudio._internal();
  factory ControladorAudio() => _instance;
  ControladorAudio._internal() {
    _inicializar();
  }

  final AudioPlayer _player = AudioPlayer();
  String? _tituloActual;
  String? _urlActual;
  bool _estaReproduciendo = false;
  Duration _posicion = Duration.zero;
  Duration _duracion = Duration.zero;

  String? get tituloActual => _tituloActual;
  String? get urlActual => _urlActual;
  bool get estaReproduciendo => _estaReproduciendo;
  Duration get posicion => _posicion;
  Duration get duracion => _duracion;
  bool get tieneAudio => _urlActual != null;

  AudioPlayer get reproductor => _player;

  Future<void> _inicializar() async {
    _player.positionStream.listen((posicion) {
      _posicion = posicion;
      notifyListeners();
    });

    _player.durationStream.listen((duracion) {
      if (duracion != null) {
        _duracion = duracion;
        notifyListeners();
      }
    });

    _player.playerStateStream.listen((state) {
      _estaReproduciendo = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _estaReproduciendo = false;
        _posicion = Duration.zero;
        _player.seek(Duration.zero);
        _player.pause();
      }
      notifyListeners();
    });
  }

  Future<void> reproducir(String titulo, String url) async {
    if (_urlActual != url) {
      _tituloActual = titulo;
      _urlActual = url;
      notifyListeners();
    }
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
    }
  }

  Future<void> pausar() async {
    await _player.pause();
  }

  Future<void> reanudar() async {
    await _player.play();
  }

  Future<void> detener() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    _tituloActual = null;
    _urlActual = null;
    _estaReproduciendo = false;
    _posicion = Duration.zero;
    _duracion = Duration.zero;
    notifyListeners();
  }

  Future<void> alternarReproduccionPausa() async {
    if (_estaReproduciendo) {
      await pausar();
    } else {
      await reanudar();
    }
  }
}

/// Helper para usar el audio desde cualquier parte de la app
void reproducirAudioGlobal(BuildContext context, String titulo, String url) {
  final audio = Provider.of<ControladorAudio>(context, listen: false);
  audio.reproducir(titulo, url);
}

/// Componente que envuelve cualquier pantalla y muestra el reproductor flotante
class EnvolturaAudioFlotante extends StatelessWidget {
  final Widget contenido;

  const EnvolturaAudioFlotante({super.key, required this.contenido});

  @override
  Widget build(BuildContext context) {
    return Consumer<ControladorAudio>(
      builder: (context, audio, _) {
        return Stack(
          children: [
            contenido,
            if (audio.tieneAudio)
              Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: _ComponenteReproductorFlotante(),
              ),
          ],
        );
      },
    );
  }
}

/// Altura total aproximada del reproductor flotante (para que otros widgets se ubiquen sobre él)
const double kAlturaReproductorFlotante = 90.0;

class _ComponenteReproductorFlotante extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audio = context.watch<ControladorAudio>();

    // Progreso entre 0.0 y 1.0 - calculado manualmente, sin LinearProgressIndicator
    final double progress = audio.duracion.inMilliseconds > 0
        ? (audio.posicion.inMilliseconds / audio.duracion.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    // ----------------------------------------------------------
    // DefaultTextStyle nuclear: resetea CUALQUIER decoración de
    // texto heredada del árbol padre antes de que llegue a los
    // widgets Text hijos. Ningún tema puede sobrescribir esto.
    // Material(transparency) reinicia el contexto sem interferir
    // con el color de fondo del Container.
    // ----------------------------------------------------------
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
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
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
                      // -- Título --
                      Text(
                        audio.tituloActual ?? 'Audio',
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
                      // -- Barra de progreso: solo Containers, cero tema --
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
                      // -- Tiempo --
                      Text(
                        '${_formatearDuracion(audio.posicion)} / ${_formatearDuracion(audio.duracion)}',
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
                  onPressed: audio.alternarReproduccionPausa,
                  icon: Icon(
                    audio.estaReproduciendo ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: audio.detener,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white60,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatearDuracion(Duration duracion) {
    String dosDigitos(int valor) => valor.toString().padLeft(2, '0');
    final minutos = dosDigitos(duracion.inMinutes.remainder(60));
    final segundos = dosDigitos(duracion.inSeconds.remainder(60));
    return '$minutos:$segundos';
  }
}
